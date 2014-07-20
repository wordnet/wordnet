namespace :wordnet do

  desc "Import wordnet database"
  task :import, [:klass] => [:environment] do |t, args|
    if args[:klass].present?
      WordnetPl.const_get(args[:klass]).new.import!

      if args[:class] == 'Sense'
        puts "Labelling sense cores..."
        Sense.label_sense_cores!
      end

      if args[:class] == 'Synset'
        puts "Labelling synset cores..."
        Sense.label_synset_cores!
      end
    else
      [
        "RelationType", "Synset", "Sense",
        "SenseRelation", "SynsetRelation"
      ].map { |c| WordnetPl.const_get(c).new.import! }

      puts "Labelling sense cores..."
      Sense.label_sense_cores!
      puts "Labelling synset cores..."
      Sense.label_synset_cores!
    end
  end

  desc "Cache synsets"
  task :cache_synsets => [:environment] do
    Synset.connection.execute "
      update synsets set
        lemma = senses.lemma,
        part_of_speech = senses.part_of_speech,
        language = senses.language
      from senses
      where senses.synset_id = synsets.id
    "
  end


  desc "Export database to Neo4j"
  task :export, [:klass] => [:environment] do |t, args|
    if args[:klass].present?
      Neo4j.const_get(args[:klass]).new.export!
    else
      [
        "Synset", "Sense",
        "SenseRelation", "SynsetRelation"
      ].map { |c| Neo4j.const_get(c).new.export! }
    end
  end

  desc "Compute all available statistics"
  task :stats, [:klass] => [:environment] do |t, args|
    Rails.logger = Logger.new(STDOUT)
    Statistic.refetch_all!(args[:klass])
  end

  desc "Reload all translations"
  task :translations => [:environment] do |t, args|
    Rails.logger = Logger.new(STDOUT)
    Translation.export
  end
end
