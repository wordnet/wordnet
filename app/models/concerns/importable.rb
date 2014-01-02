module Importable
  extend ActiveSupport::Concern

  module ClassMethods

    def wordnet_connection
      Sequel.connect('mysql2://root@localhost/wordnet', :max_connections => 10)
    end

    def wordnet_import!(options = {}, connection = self.wordnet_connection)
      batch_size = options.fetch(:batch_size, 500)
      pool_size = options.fetch(:pool_size, 2)
      pages = options.fetch(:pages,
        (self.wordnet_count(connection).to_f / batch_size).ceil
      )

      progressbar = ProgressBar.create(
        :title => self.to_s.split('::').last,
        :total => pages,
        :format => "%t: |%B| %c/%C %E",
        :smoothing => 0.8
      )

      mutex = Mutex.new
      pool = Thread.pool(pool_size)
      conn = self.connection
      table = self.table_name

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

            mutex.synchronize do
              Upsert.batch(conn, table) do |upsert|
                entities.each do |hash|
                  unique_map = Hash[unique_attributes.map { |a| [a, hash.delete(a)] }]
                  upsert.row(unique_map, hash)
                end
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
