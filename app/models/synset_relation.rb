class SynsetRelation < ActiveRecord::Base

  belongs_to :parent, :class_name => "Synset"
  belongs_to :child, :class_name => "Synset"

  include Importable

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

end
