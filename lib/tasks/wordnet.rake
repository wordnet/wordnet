namespace :wordnet do
  desc "Import wordnet database"

  task :import, [:klass] => [:environment] do |t, args|
    if args[:klass].present?
      WordnetPl.const_get(args[:klass]).new.import!
    else
      [
        "RelationType", "Sense", "Synset", "SynsetSense",
        "SenseRelation", "SynsetRelation"
      ].map { |c| WordnetPl.const_get(c).new.import! }
    end
  end

  task :export, [:klass] => [:environment] do |t, args|
    if args[:klass].present?
      Object.const_get(args[:klass]).neo4j_export!
    else
      [
        Lexeme, Sense, Synset,
        SynsetSense, SenseRelation, SynsetRelation
      ].map(&:neo4j_export!)
    end
  end
end
