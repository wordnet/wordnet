class SynsetRelation < ActiveRecord::Base

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
    if options[:only_child]
      {
        child: child.as_json(:only_lemma => true),
        relation_id: relation_id
      }
    elsif options[:only_parent]
      {
        parent: parent.as_json(:only_lemma => true),
        relation_id: relation_id
      }
    end
  end
end
