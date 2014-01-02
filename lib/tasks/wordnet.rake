namespace :wordnet do
  desc "Import wordnet database"

  task :import, [:klass] => [:environment] do |t, args|
    if args[:klass].present?
      Object.const_get(args[:klass]).wordnet_import!
    else
      [
        Lexeme, Sense, Synset,
        LexemeSense, SynsetSense,
        SenseRelation, SynsetRelation
      ].map(&:wordnet_import!)
    end
  end

  task :export, [:klass] => [:environment] do |t, args|
    if args[:klass].present?
      Object.const_get(args[:klass]).neo4j_export!
    else
      [
        Lexeme, Sense, Synset,
        LexemeSense, SynsetSense,
        SenseRelation, SynsetRelation
      ].map(&:neo4j_export!)
    end
  end
end
