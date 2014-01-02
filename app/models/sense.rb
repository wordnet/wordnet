class Sense < ActiveRecord::Base

  has_many :lexemes, through: :lexeme_senses
  has_many :lexeme_senses

  include Importable
  include Exportable

  def self.unique_attributes
    [:external_id]
  end

  def self.wordnet_count(connection)
    connection[:lexicalunit].max(:ID)
  end

  def self.wordnet_load(connection, offset, limit)
    raw = connection[:lexicalunit].select(:ID, :comment, :domain).order(:ID).
      where('ID >= ? AND ID < ?', offset, offset + limit).to_a

    raw.map do |lemma|
      {
        external_id: lemma[:ID],
        domain_id: lemma[:domain],
        comment: lemma[:comment] == "brak danych" ? nil : lemma[:comment].presence
      }
    end
  end

end
