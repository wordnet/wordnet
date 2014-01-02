class Sense < ActiveRecord::Base

  has_many :lexemes, through: :lexeme_senses
  has_many :lexeme_senses

  has_many :child_relations, :foreign_key => "parent_id",
    :class_name => "SenseRelation"

  has_many :parent_relations, :foreign_key => "child_id",
    :class_name => "SenseRelation"

  has_many :synset_senses
  has_many :synsets, through: :synset_senses

  def synset
    synsets.first
  end

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

  def as_json(options = {})
    if options[:only_lemma]
      super.merge(
        :lemma => lexemes.first.lemma
      )
    else
      super.merge(
        :synsets => synsets.map { |s| s.as_json(:only_lemmas => true) }
      )
    end
  end

end
