class Synset < ActiveRecord::Base

  has_many :senses

  has_many :related, :foreign_key => "parent_id",
    :class_name => "SynsetRelation"

  has_many :reverse_related, :foreign_key => "child_id",
    :class_name => "SynsetRelation"

  def as_json(options = {})
    {
      senses: senses.order(:sense_index).as_json,
      comment: comment,
      definition: definition,
      examples: examples
    }
  end
end
