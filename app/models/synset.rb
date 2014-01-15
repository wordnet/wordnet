class Synset < ActiveRecord::Base

  has_many :senses

  has_many :relations, :foreign_key => "parent_id",
    :class_name => "SynsetRelation"

  has_many :reverse_relations, :foreign_key => "child_id",
    :class_name => "SynsetRelation"

  def as_json(options = {})
    senses.order(:sense_index).first.as_json
  end

  def export_query
    "MERGE (n:#{self.name} { id: {id} })"
  end

  def export_properties(entity)
    { id: entity.id }
  end
end
