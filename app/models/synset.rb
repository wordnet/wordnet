class Synset < ActiveRecord::Base

  has_many :senses, :through => :synset_senses
  has_many :synset_senses

  has_many :child_relations, :foreign_key => "parent_id",
    :class_name => "SynsetRelation"

  has_many :parent_relations, :foreign_key => "child_id",
    :class_name => "SynsetRelation"

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

  def as_json(options = {})
    if options[:only_lemmas]
      super.merge(
        lemmas: senses.flat_map { |s| s.lexemes.select(:lemma).map(&:lemma) }
      )
    else
      super.merge(
        senses: senses.map { |s| s.as_json(:only_lemma => true) }
      )
    end
  end
end
