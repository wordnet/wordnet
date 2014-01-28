require 'progress_bar_exporter'
require 'thread_pool_exporter'
require 'synchronized_write_exporter'

class Exporter
  prepend ProgressBarExporter
  # prepend ThreadPoolExporter
  prepend SynchronizedWriteExporter

  def source
    raise NotImplementedError.new("You must implement source.")
  end

  def export_properties(entity)
    raise NotImplementedError.new("You must implement export_properties.")
  end

  def export_query(entry)
    raise NotImplementedError.new("You must implement export_query.")
  end

  def initialize(options = {})
    @connection = Neography::Rest.new(Figaro.env.neo4j_url)
    @batch_size = options.fetch(:batch_size, 500)
    @pages = options.fetch(:pages, (source.count.to_f / @batch_size).ceil)
  end

  def export!
    export_index!
    source.find_in_batches(batch_size: @batch_size) do |batch|
      export_entities!(batch)
    end
  end

  def export_index!
    if @connection.get_schema_index(source.name).empty?
      @connection.create_schema_index(source.name, "id")
    end
  end

  def export_entities!(entities)
    persist_entities!(prepare_batch(entities))
  end

  def prepare_batch(entities)
    entities.map do |entity|
      [:execute_query, export_query(entity), export_properties(entity)]
    end
  end

  def persist_entities!(batch)
    @connection.batch(*batch)
  end

end
