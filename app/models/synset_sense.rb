class SynsetSense < ActiveRecord::Base

  belongs_to :synset
  belongs_to :sense

  def self.export_index(connection)
    nil
  end

  def self.export_query
    "MATCH (a:Sense { id: {sense_id} }), " +
          "(b:Synset { id: {synset_id} }) " +
    "MERGE (a)-[r:belongs_to]->(b)"
  end

  def self.export_properties(entity)
    { synset_id: entity.synset_id, sense_id: entity.sense_id }
  end

end

