class Statistic < ActiveRecord::Base

  DIMENSIONS = Hashie::Mash.new
  STATISTICS = Hashie::Mash.new
  VIEWS      = []

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

    def table_view(name, options = {})
      rows = options[:stats].map do |stat|
        stat.send(options[:rows])
      end.uniq.sort_by(&options[:rows_sorting])

      columns = options[:stats].map do |stat|
        stat.send(options[:columns])
      end.uniq.sort_by(&options[:columns_sorting])

      stats = options[:stats]
      stats = stats.group_by(&options[:rows])
      stats = Hash[stats.map do |key, values|
        [key, values.index_by(&options[:columns])]
      end]

      formatter = options[:formatter] || :to_f.to_proc

      table = rows.map do |row|
        values = columns.map do |column|
          formatter[stats[row][column].try(:value) || 0.0]
        end

        if options[:sum]
          [*values, values.reduce(0, :+)]
        else
          values
        end
      end

      {
        name: name,
        type: 'table',
        rows: rows,
        columns: columns + (options[:sum] ? ['sum'] : []),
        data: table
      }
    end

    def def_view(&block)
      VIEWS << block
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
    find_by(name: name, x: points[0], y: points[1]) || begin
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

  def self.fetch_all(names = [], *points)
    x, y = points

    if y.present?
      where.not(value: 0).where(name: names, x: x, y: y).load
    elsif x.present?
      where.not(value: 0).where(name: names, x: x).load
    elsif names.present?
      where.not(value: 0).where(name: names).load
    else
      where.not(value: 0).load
    end
  end

  def self.fetch_all!(names = [], *points)
    if names.blank?
      names = STATISTICS.keys
    end

    [*names].flat_map do |name|
      unless statistic = STATISTICS[name]
        raise ArgumentError.new("Unknown statistic: #{name}")
      end

      xd, yd = statistic.dimensions.map do |dim_name|
        DIMENSIONS[dim_name].call
      end

      xd = [*points[0]] if xd && points[0]
      yd = [*points[1]] if yd && points[1]

      if xd.nil? && yd.nil?
        [fetch!(name)]
      else
        arguments_array = xd.product(yd || [nil]).map(&:compact)
        arguments_array.map do |args|
          fetch!(name, *args)
        end
      end
    end
  end

  def self.refetch_all!(name = [], *points)
    fetch_all(name, *points).delete_all
    fetch_all!(name, *points)
  end

  def_dimension "pos" do
    PartOfSpeech.all.map(&:uuid)
  end

  def_dimension "int_pos" do
    ['noun', 'verb', 'adjective', 'adverb']
  end

  def_dimension "size" do
    (1..10).map(&:to_s)
  end

  def_dimension "relation" do
    RelationType.pluck(:id).map(&:to_s).map { |r| "relation_#{r}" }
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

  def_statistic "polysemous_lemmas", ["pos"] do |pos|
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

  def_statistic "polysemy", ["pos"] do |pos|
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

  def_statistic "polysemy_nomono", ["pos"] do |pos|
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
          select count(distinct synset_id)
          from senses
          where senses.lemma = lemmas.lemma
        ) as synset_count
        from (
          select distinct lemma
          from senses
          where senses.part_of_speech = '#{pos}'
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

  def_statistic "pl_synset_relations", ["relation", "pos"] do |rel, pos|
    SynsetRelation.select(:id).joins(:parent, :child).where(:relation_id => 208, :synsets => { :language => 'pl_PL' }, :children_synset_relations => { :language => 'pl_PL' }).count
  end

  def_statistic "en_synset_relations", ["relation", "pos"] do |rel, pos|
    SynsetRelation.
      select(:id).
      joins(:parent, :child).
      where(:relation_id => rel.split('_').last.to_i,
        :synsets => {
          :part_of_speech => pos,
          :language => 'en_GB'
        },
        :children_synset_relations => {
          :part_of_speech => pos,
          :language => 'en_GB'
        }
      ).
      count
  end

  def_statistic "int_synset_relations", ["relation", "int_pos"] do |rel, pos|
    SynsetRelation.
      select(:id).
      joins(:parent, :child).
      where(:relation_id => rel.split('_').last.to_i,
        :synsets => {
          :part_of_speech => ["#{pos}_pl", "#{pos}_pwn"],
          :language => 'pl_PL'
        },
        :children_synset_relations => {
          :part_of_speech => ["#{pos}_pl", "#{pos}_pwn"],
          :language => 'en_GB'
        }
      ).
      count +
    SynsetRelation.
      select(:id).
      joins(:parent, :child).
      where(:relation_id => rel.split('_').last.to_i,
        :synsets => {
          :part_of_speech => ["#{pos}_pl", "#{pos}_pwn"],
          :language => 'en_GB'
        },
        :children_synset_relations => {
          :part_of_speech => ["#{pos}_pl", "#{pos}_pwn"],
          :language => 'pl_PL'
        }
      ).
      count
  end

  def_statistic "pl_sense_relations", ["relation", "pos"] do |rel, pos|
    SenseRelation.
      select(:id).
      joins(:parent, :child).
      where(:relation_id => rel.split('_').last.to_i,
        :senses => {
          :part_of_speech => pos,
          :language => 'pl_PL'
        },
        :children_sense_relations => {
          :part_of_speech => pos,
          :language => 'pl_PL'
        }
      ).
      count
  end

  def_statistic "en_sense_relations", ["relation", "pos"] do |rel, pos|
    SenseRelation.
      select(:id).
      joins(:parent, :child).
      where(:relation_id => rel.split('_').last.to_i,
        :senses => {
          :part_of_speech => pos,
          :language => 'en_GB'
        },
        :children_sense_relations => {
          :part_of_speech => pos,
          :language => 'en_GB'
        }
      ).
      count
  end

  def_statistic "int_sense_relations", ["relation", "int_pos"] do |rel, pos|
    SenseRelation.
      select(:id).
      joins(:parent, :child).
      where(:relation_id => rel.split('_').last.to_i,
        :senses => {
          :part_of_speech => ["#{pos}_pl", "#{pos}_pwn"],
          :language => 'pl_PL'
        },
        :children_sense_relations => {
          :part_of_speech => ["#{pos}_pl", "#{pos}_pwn"],
          :language => 'en_GB'
        }
      ).
      count + 
    SenseRelation.
      select(:id).
      joins(:parent, :child).
      where(:relation_id => rel.split('_').last.to_i,
        :senses => {
          :part_of_speech => pos.split('_').first + '_pwn',
          :language => 'en_GB'
        },
        :children_sense_relations => {
          :part_of_speech => pos.split('_').first + '_pl',
          :language => 'pl_PL'
        }
      ).
      count
  end

  def_view do
    poss = DIMENSIONS['pos'].call

    stats = fetch_all(
      ['lemmas', 'lexemes', 'synsets',
       'monosemous_lemmas', 'polysemous_lemmas'],
      ['verb_pl', 'noun_pl', 'adjective_pl']
    )

    table_view "aspects_of_plwordnet",
      columns: :x,
      rows: :name,
      columns_sorting: lambda { |element|
        poss.index(element)
      },
      rows_sorting: lambda { |element|
        ['lemmas', 'lexemes', 'synsets',
         'monosemous_lemmas', 'polysemous_lemmas'].index(element)
      },
      formatter: lambda { |value|
        value.to_i
      },
      stats: stats,
      sum: true
  end

  def_view do
    poss = DIMENSIONS['pos'].call

    stats = fetch_all(
      ['lemmas', 'lexemes', 'synsets',
       'monosemous_lemmas', 'polysemous_lemmas'],
      ['verb_pwn', 'noun_pwn', 'adjective_pwn']
    )

    table_view "aspects_of_enwordnet",
      columns: :x,
      rows: :name,
      columns_sorting: lambda { |element|
        poss.index(element)
      },
      rows_sorting: lambda { |element|
        ['lemmas', 'lexemes', 'synsets',
         'monosemous_lemmas', 'polysemous_lemmas'].index(element)
      },
      formatter: lambda { |value|
        value.to_i
      },
      stats: stats,
      sum: true
  end

  def_view do
    poss = DIMENSIONS['pos'].call

    stats = fetch_all(
      ['polysemy', 'polysemy_nomono'],
      poss
    )

    table_view "average_polysemy",
      columns: :name,
      rows: :x,
      columns_sorting: lambda { |element|
        ['polysemy', 'polysemy_nomono'].index(element)
      },
      rows_sorting: lambda { |element|
        poss.index(element)
      },
      stats: stats
  end

  def_view do
    poss = DIMENSIONS['pos'].call
    sizes = DIMENSIONS['size'].call

    stats = fetch_all(
      'synset_size_ratio',
      poss,
      sizes
    )

    table_view "synset_size_ratio",
      columns: :y,
      rows: :x,
      columns_sorting: lambda { |element|
        sizes.index(element)
      },
      rows_sorting: lambda { |element|
        poss.index(element)
      },
      stats: stats
  end

  def_view do
    poss = DIMENSIONS['pos'].call
    sizes = DIMENSIONS['size'].call

    stats = fetch_all(
      'lemma_synsets_ratio',
      poss,
      sizes
    )

    table_view "lemma_synsets_ratio",
      columns: :y,
      rows: :x,
      columns_sorting: lambda { |element|
        sizes.index(element)
      },
      rows_sorting: lambda { |element|
        poss.index(element)
      },
      stats: stats
  end

  def_view do
    poss = DIMENSIONS['pos'].call
    relations = DIMENSIONS['relation'].call

    stats = fetch_all(
      'pl_synset_relations',
      relations,
      ['verb_pl', 'noun_pl', 'adjective_pl']
    )

    table_view "pl_synset_relations",
      columns: :y,
      rows: :x,
      columns_sorting: lambda { |element|
        poss.index(element)
      },
      rows_sorting: lambda { |element|
        relations.index(element)
      },
      stats: stats,
      sum: true
  end

  def_view do
    poss = DIMENSIONS['pos'].call
    relations = DIMENSIONS['relation'].call

    stats = fetch_all(
      'pl_sense_relations',
      relations,
      ['verb_pl', 'noun_pl', 'adjective_pl']
    )

    table_view "pl_sense_relations",
      columns: :y,
      rows: :x,
      columns_sorting: lambda { |element|
        poss.index(element)
      },
      rows_sorting: lambda { |element|
        relations.index(element)
      },
      stats: stats,
      sum: true
  end

  def_view do
    poss = DIMENSIONS['pos'].call
    relations = DIMENSIONS['relation'].call

    stats = fetch_all(
      'en_synset_relations',
      relations,
      ['verb_pwn', 'noun_pwn', 'adverb_pwn', 'adjective_pwn']
    )

    table_view "en_synset_relations",
      columns: :y,
      rows: :x,
      columns_sorting: lambda { |element|
        poss.index(element)
      },
      rows_sorting: lambda { |element|
        relations.index(element)
      },
      stats: stats,
      sum: true
  end

  def_view do
    poss = DIMENSIONS['pos'].call
    relations = DIMENSIONS['relation'].call

    stats = fetch_all(
      'en_sense_relations',
      relations,
      ['verb_pwn', 'noun_pwn', 'adverb_pwn', 'adjective_pwn']
    )

    table_view "en_sense_relations",
      columns: :y,
      rows: :x,
      columns_sorting: lambda { |element|
        poss.index(element)
      },
      rows_sorting: lambda { |element|
        relations.index(element)
      },
      stats: stats,
      sum: true
  end

  def_view do
    poss = DIMENSIONS['pos'].call
    relations = DIMENSIONS['relation'].call

    stats = fetch_all(
      'int_sense_relations',
      relations,
      ['verb', 'noun', 'adverb', 'adjective']
    )

    table_view "int_sense_relations",
      columns: :y,
      rows: :x,
      columns_sorting: lambda { |element|
        poss.index(element)
      },
      rows_sorting: lambda { |element|
        relations.index(element)
      },
      stats: stats,
      sum: true
  end

  def_view do
    poss = DIMENSIONS['pos'].call
    relations = DIMENSIONS['relation'].call

    stats = fetch_all(
      'int_synset_relations',
      relations,
      ['verb', 'noun', 'adverb', 'adjective']
    )

    table_view "int_synset_relations",
      columns: :y,
      rows: :x,
      columns_sorting: lambda { |element|
        poss.index(element)
      },
      rows_sorting: lambda { |element|
        relations.index(element)
      },
      stats: stats,
      sum: true
  end
end
