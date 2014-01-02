module Importable
  extend ActiveSupport::Concern

  module ClassMethods

    def wordnet_connection
      Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
    end

    def wordnet_import!(options = {}, connection = self.wordnet_connection)
      batch_size = options.fetch(:batch_size, 300)
      pool_size = options.fetch(:pool_size, 3)
      pages = options.fetch(:pages,
        (self.wordnet_count(connection).to_f / batch_size).ceil
      )

      progressbar = ProgressBar.create(
        :title => self.to_s.split('::').last,
        :total => pages,
        :format => "%t: |%B| %c/%C %E",
        :smoothing => 0.8
      )

      pool = Thread.pool(pool_size)

      (0...pages).each do |page|
        pool.process do
          begin
            entities = self.wordnet_load(connection, page * batch_size, batch_size)

            if respond_to?(:uuid_mappings)
              uuid_mappings.each do |key, opts|
                uuid_mapping = Hash[opts[:model].select(:id, opts[:attribute]).
                  where(opts[:attribute] => entities.map { |w| w[key] }).
                  map { |w| [w[opts[:attribute]], w[:id]] }]

                entities.each do |entity|
                  entity[key] = uuid_mapping[entity.delete(key)]
                end

                entities.select! { |w| w[key].present? }
              end
            end

            entities.each do |hash|
              unique_map = Hash[unique_attributes.map { |a| [a, hash[a]] }]

              if entity = self.find_by(unique_map)
                # entity.update(hash) rescue nil
              else
                self.create(hash) rescue nil
              end
            end

          rescue => e
            puts e.message
          ensure
            progressbar.increment
          end
        end
      end

      pool.shutdown

      progressbar.finish
    end

  end

end
