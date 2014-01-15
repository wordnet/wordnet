namespace :wordnet do
  desc "Import wordnet database"

  task :import, [:klass] => [:environment] do |t, args|
    if args[:klass].present?
      WordnetPl.const_get(args[:klass]).new.import!
    else
      [
        "Sense", "Synset", "SynsetSense",
        "SenseRelation", "SynsetRelation"
      ].map { |c| WordnetPl.const_get(c).new.import! }
    end
  end

  task :export, [:klass] => [:environment] do |t, args|
    if args[:klass].present?
      Neo4j.const_get(args[:klass]).new.export!
    else
      [
        "Sense", "Synset", "SynsetSense",
        "SenseRelation", "SynsetRelation"
      ].map { |c| Neo4j.const_get(c).new.export! }
    end
  end
end
