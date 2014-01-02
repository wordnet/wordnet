class Synset < ActiveRecord::Base

  has_many :senses, :through => :synset_senses
  has_many :synset_senses
  has_many :synset_relations, :foreign_key => "parent_id"

  include Importable
  include Exportable

  def self.unique_attributes
    [:external_id]
  end

  def self.wordnet_count(connection)
    connection[:synset].max(:ID)
  end

  def self.wordnet_load(connection, offset, limit)
    raw = connection[:synset].select(:ID, :comment, :definition).order(:ID).
      where('ID >= ? AND ID < ?', offset, offset + limit).to_a

    raw.map do |synset|
      {
        external_id: synset[:ID],
        comment: synset[:comment],
        definition: synset[:definition] == "brak danych" ? nil : synset[:definition].presence
      }
    end
  end

end
