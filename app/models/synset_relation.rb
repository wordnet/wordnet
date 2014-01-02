class SynsetRelation < ActiveRecord::Base

  belongs_to :parent, :class_name => "Synset"
  belongs_to :child, :class_name => "Synset"

  include Importable
  include Exportable

  def self.uuid_mappings
    {
      :parent_id => { model: Synset, attribute: :external_id },
      :child_id => { model: Synset, attribute: :external_id }
    }
  end

  def self.unique_attributes
    [:parent_id, :child_id, :relation_id]
  end

  def self.wordnet_count(connection)
    connection[:synsetrelation].max(:PARENT_ID)
  end

  def self.wordnet_load(connection, offset, limit)
    raw = connection[:synsetrelation].select(:PARENT_ID, :CHILD_ID, :REL_ID).
      where('PARENT_ID >= ? AND PARENT_ID < ?', offset, offset + limit).to_a

    raw.map do |relation|
      {
        relation_id: relation[:REL_ID],
        parent_id: relation[:PARENT_ID],
        child_id: relation[:CHILD_ID]
      }
    end
  end

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
