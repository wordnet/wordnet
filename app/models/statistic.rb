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
      where(name: name, x: x, y: y).load
    elsif x.present?
      where(name: name, x: x).load
    elsif name.present?
      where(name: name).load
    else
      all.load
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

  def self.refetch_all!(name, *points)
    fetch_all(name, *points).delete_all
    fetch_all!(name, *points)
  end

  def_dimension "pos" do
    PartOfSpeech.all.map(&:uuid)
  end

  def_dimension "size" do
    (1..10).map(&:to_s)
  end

  def_dimension "relation" do
    RelationType.pluck(:id).map(&:to_s)
  end

  def_statistic "lemmas", ["pos"] do |pos|
    Sense.
      where(:part_of_speech => pos).
      distinct.count(:lemma)
  end

  def_statistic "monosemous_lemmas", ["pos"] do |pos|
    Sense.
      where(:part_of_speech => pos).
      where('
        not exists (select * from senses as s2
        where s2.lemma = senses.lemma and s2.id != senses.id)
      '.squish).
      distinct.count(:lemma)
  end

  def_statistic "polisemous_lemmas", ["pos"] do |pos|
    Sense.
      where(:part_of_speech => pos).
      where('
        exists (select * from senses as s2
        where s2.lemma = senses.lemma and s2.id != senses.id)
      '.squish).
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

  def_statistic "polisemy", ["pos"] do |pos|
    subquery = Sense.
      where(:part_of_speech => pos).
      group(:lemma).
      select('count(lemma) as lemma_count').
      to_sql

    Sense.connection.
      select_all(
        "select avg(lemma_count) as average from (%s) as s" % 
        subquery
    )[0]["average"].to_f.round(2)
  end

  def_statistic "polisemy_nomono", ["pos"] do |pos|
    subquery = Sense.
      where(:part_of_speech => pos).
      group(:lemma).
      where('
        exists (select * from senses as s2
        where s2.lemma = senses.lemma and s2.id != senses.id)
      '.squish).
      select('count(lemma) as lemma_count').
      to_sql

    Sense.connection.
      select_all(
        "select avg(lemma_count) as average from (%s) as s" % 
        subquery
    )[0]["average"].to_f.round(2)
  end

  def_statistic "synset_size_ratio", ["pos", "size"] do |pos, size|
    of_size_count = Sense.connection.
      select_all("select count(*) from (%s) as senses" % 
      Sense.where(:part_of_speech => pos).
      group(:synset_id).select('count(*)').
      having("count(*) = #{size}").to_sql)[0]["count"].to_f 

    all_count = fetch!('synsets', pos).value

    ((of_size_count / all_count) * 100).round(2)
  end

  def_statistic "lemma_synsets_ratio", ["pos", "size"] do |pos, size|
    of_size_count = Sense.connection.select_all("
      select count(*) from (
        select lemma, (
          select count(distinct synset_id) as synset_count
          from senses where senses.lemma = lemmas.lemma
        ) from (
          select distinct lemma from senses where senses.part_of_speech = '#{pos}'
        ) as lemmas
      ) as stats
      where stats.synset_count = #{size}
    ")[0]["count"].to_f
    
    all_count = Sense.
      where(:part_of_speech => pos).
      distinct.
      count(:lemma)

    ((of_size_count / all_count) * 100).round(2)
  end

  def_statistic "synset_relations", ["relation", "pos"] do |rel, pos|
    SynsetRelation.
      where("synset_relations.parent_id IN (#{
        Synset.
          joins(:senses).
          where('senses.part_of_speech = ?', pos).
          select('synsets.id').to_sql
      })").
      where(:relation_id => rel.to_i).
      count
  end

  def_statistic "sense_relations", ["relation", "pos"] do |rel, pos|
    SenseRelation.
      select(:id).
      joins(:parent).
      where(:relation_id => rel.to_i, :senses => {
        :part_of_speech => pos
      }).
      count
  end

end
