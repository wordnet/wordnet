class SynsetRelation < ActiveRecord::Base

  include Exportable

  belongs_to :parent, :class_name => "Synset"
  belongs_to :child, :class_name => "Synset"

  def self.export_index(connection)
    nil
  end

  def self.export_query
    "MATCH (a:Synset { id: {parent_id} }), " +
          "(b:Synset { id: {child_id} }) " +
    "MERGE (a)-[r:relation { id: {relation_id} }]->(b)"
  end

  def self.export_properties(entity)
    { parent_id: entity.parent_id, child_id: entity.child_id, relation_id: entity.relation_id }
  end

  def as_json(options = {})
    if options[:reverse]
      { relation_id: relation_id, synset: true, target: parent.as_json }
    else
      { relation_id: relation_id, synset: true, target: child.as_json }
    end
  end
end
