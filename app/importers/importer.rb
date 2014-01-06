require 'progress_bar_importer'
require 'thread_pool_importer'

class Importer
  prepend ProgressBarImporter
  prepend ThreadPoolImporter

  def total_count
    raise NotImplementedError.new("You must implement total_count.")
  end

  def load_entities(offset, limit)
    raise NotImplementedError.new("You must implement load_entities.")
  end

  def table_name
    raise NotImplementedError.new("You must implement table_name.")
  end

  def initialize(options = {})
    @base_connection = options.fetch(:connection, ActiveRecord::Base.connection)
    @sequel_connection = Sequel.connect(
      Rails.configuration.database_configuration[Rails.env].
        merge("adapter" => "postgres")
    )

    @batch_size = options.fetch(:batch_size, 500)
    @pages = options.fetch(:pages, (total_count.to_f / @batch_size).ceil)
    @mutex = Mutex.new
  end

  def import!
    (0...@pages).each do |page|
      import_entities!(@batch_size, page * @batch_size)
    end
  end

  def import_entities!(limit, offset)
    entities = load_entities(limit, offset)

    if respond_to?(:uuid_mappings)
      uuid_mappings.each do |key, opts|
        uuid_mapping = Hash[
          @sequel_connection[opts[:table]].select(:id, opts[:attribute]).
          where(opts[:attribute] => entities.map { |w| w[key] }).to_a.
          map { |w| [w[opts[:attribute]], w[:id]] }
        ]

        entities.each do |entity|
          entity[key] = uuid_mapping[entity.delete(key)]
        end

        entities.select! { |w| w[key].present? }
      end
    end

    @mutex.synchronize do
      Upsert.batch(@base_connection, table_name) do |upsert|
        entities.each do |hash|
          unique_map = Hash[unique_attributes.map { |a| [a, hash.delete(a)] }]
          upsert.row(unique_map, hash)
        end
      end
    end
  end

end
