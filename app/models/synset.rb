class Synset < ActiveRecord::Base

  has_many :senses, :through => :synset_senses
  has_many :synset_senses

  has_many :child_relations, :foreign_key => "parent_id",
    :class_name => "SynsetRelation"

  has_many :parent_relations, :foreign_key => "child_id",
    :class_name => "SynsetRelation"

  def as_json(options = {})
    if options[:only_lemmas]
      super.merge(
        lemmas: senses.map(&:lexeme).map(&:lemma)
      )
    else
      super.merge(
        senses: senses.map { |s| s.as_json(:only_lemma => true) }
      )
    end
  end
end
