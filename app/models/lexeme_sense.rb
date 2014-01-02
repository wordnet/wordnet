class LexemeSense < ActiveRecord::Base
  include Importable

  belongs_to :lexeme
  belongs_to :sense

  def self.uuid_mappings
    {
      :sense_id => { model: Sense, attribute: :external_id },
      :lexeme_id => { model: Lexeme, attribute: :lemma }
    }
  end

  def self.unique_attributes
    [:lexeme_id, :sense_id]
  end

  def self.wordnet_count(connection)
    connection[:lexicalunit].max(:ID)
  end

  def self.wordnet_load(connection, offset, limit)
    raw = connection[:lexicalunit].select(:ID, :lemma).order(:ID).
      where('ID >= ? AND ID < ?', offset, offset + limit).to_a

    raw.map do |lemma|
      { sense_id: lemma[:ID], lexeme_id: lemma[:lemma] }
    end
  end

end
