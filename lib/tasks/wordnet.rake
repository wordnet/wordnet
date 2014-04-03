namespace :wordnet do

  desc "Import wordnet database"
  task :import, [:klass] => [:environment] do |t, args|
    if args[:klass].present?
      WordnetPl.const_get(args[:klass]).new.import!
    else
      [
        "RelationType", "Synset", "Sense",
        "SenseRelation", "SynsetRelation"
      ].map { |c| WordnetPl.const_get(c).new.import! }
    end
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
end
