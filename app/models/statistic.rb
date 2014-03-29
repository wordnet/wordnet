class Statistic < ActiveRecord::Base

  DIMENSIONS = Hashie::Mash.new
  STATISTICS = Hashie::Mash.new

  class << self
    def def_dimension(name, &block)
      DIMENSIONS[name] = block
    end

    def def_statistic(name, dimensions = [], &block)
      dimensions.map do |dimension|
        unless DIMENSIONS[dimension]
          raise ArgumentError.new("Unknown dimension: #{dimension}")
        end
      end

      STATISTICS[name] = Hashie::Mash[{
        name: name,
        dimensions: dimensions,
        constructor: block
      }]
    end
  end

  def self.definitions
    STATISTICS.map do |name, statistic|
      {
        name: statistic.name,
        dimensions: statistic.dimensions.map do |d|
          {
            name: d,
            domain: DIMENSIONS[d].call
          }
        end
      }
    end
  end

  def self.fetch(name, *points)
    unless statistic = STATISTICS[name]
      raise ArgumentError.new("Unknown statistic: #{name}")
    end

    unless points.size == statistic.dimensions.size
      raise ArgumentError.new(
        "#{name} requires #{statistic.dimensions.size} points"
      )
    end

    Statistic.new(
      name: name,
      x: points[0],
      y: points[1],
      value: statistic.constructor.call(*points)
    )
  end

  def self.fetch!(name, *points)
    record = find_by(name: name, x: points[0], y: points[1]) || begin
      Rails.logger.info("Fetching statistic #{name}(#{points.join(',')})")
      fetch(name, *points).tap { |r| r.save }
    end
  end

  def self.refetch!(name, *points)
    transaction do
      if record = find_by(name: name, x: points[0], y: points[1])
        record.destroy
      end

      fetch!(name, *points)
    end
  end

  def self.fetch_all(name = nil, *points)
    x, y = points

    if y.present?
      where(name: name, x: x, y: y).to_a
    elsif x.present?
      where(name: name, x: x).to_a
    elsif name.present?
      where(name: name).to_a
    else
      all.to_a
    end
  end

  def self.fetch_all!(name = nil, *points)
    if name.nil?
      return STATISTICS.keys.flat_map { |s| fetch_all!(s) }
    end

    unless statistic = STATISTICS[name]
      raise ArgumentError.new("Unknown statistic: #{name}")
    end

    xd, yd = statistic.dimensions.map do |dim_name|
      DIMENSIONS[dim_name].call
    end

    xd = [points[0]] if xd && points[0]
    yd = [points[1]] if yd && points[1]

    if xd.nil? && yd.nil?
      [fetch!(name)]
    else
      arguments_array = xd.product(yd || [nil]).map(&:compact)
      arguments_array.map do |args|
        fetch!(name, *args)
      end
    end
  end

  def_dimension "pos" do
    PartOfSpeech.all.map(&:uuid)
  end

  def_dimension "size" do
    (1..10).map(&:to_s)
  end

  def_statistic "lemmas", ["pos"] do |pos|
    Sense.
      where(:part_of_speech => pos).
      distinct.count(:lemma)
  end

  def_statistic "lexemes", ["pos"] do |pos|
    Sense.
      where(:part_of_speech => pos).
      count
  end

  def_statistic "synsets", ["pos"] do |pos|
    Sense.
      where(:part_of_speech => pos).
      distinct.count(:synset_id)
  end
end
