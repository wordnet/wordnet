class Sense < ActiveRecord::Base

  belongs_to :lexeme

  has_many :child_relations, :foreign_key => "parent_id",
    :class_name => "SenseRelation"

  has_many :parent_relations, :foreign_key => "child_id",
    :class_name => "SenseRelation"

  has_many :synset_senses
  has_many :synsets, through: :synset_senses

  def synset
    synsets.first
  end

  def as_json(options = {})
    if options[:only_lemma]
      super.merge(
        :lemma => lexeme.lemma
      )
    else
      super.merge(
        :synsets => synsets.map { |s| s.as_json(:only_lemmas => true) }
      )
    end
  end

end
