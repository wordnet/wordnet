class Synset < ActiveRecord::Base

  has_many :senses

  has_many :related, :foreign_key => "parent_id",
    :class_name => "SynsetRelation"

  has_many :reverse_related, :foreign_key => "child_id",
    :class_name => "SynsetRelation"

  def as_json(options = {})
    the_senses = senses.order(:sense_index)

    if options[:without]
      the_senses = the_senses.where.not(id: options[:without])
    end

    {
      senses: the_senses.as_json,
      comment: comment,
      definition: definition
    }
  end
end
