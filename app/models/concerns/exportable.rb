module Exportable
  extend ActiveSupport::Concern

  module ClassMethods

    def neo4j_export!(options = {}, connection = Neography::Rest.new)
      batch_size = options.fetch(:batch_size, 500)

      query = self.export_query # cache

      progressbar = ProgressBar.create(
        :title => self.to_s.split('::').last,
        :total => (count.to_f / batch_size).ceil,
        :format => "%t: |%B| %c/%C %E",
        :smoothing => 0.8
      )

      if connection.get_schema_index(self.name).empty?
        self.export_index(connection)
      end

      pool = Thread.pool(2)

      mutex = Mutex.new

      find_in_batches(batch_size: batch_size) do |batch|
        pool.process do
          begin
            queries = batch.map do |entry|
              [:execute_query, query, export_properties(entry)]
            end

            mutex.synchronize do
              connection.batch(*queries)
            end
          rescue Exception => e
            puts e.message
          ensure
            progressbar.increment
          end
        end
      end

      pool.shutdown
    end

    def export_index(connection)
      connection.create_schema_index(self.name, "id")
    end

    def export_query
      "MERGE (n:#{self.name} { id: {id} })"
    end

    def export_properties(entity)
      { id: entity.id }
    end
  end

end
