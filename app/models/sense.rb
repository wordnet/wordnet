class Sense < ActiveRecord::Base

  belongs_to :lexeme

  has_many :relations, :foreign_key => "parent_id",
    :class_name => "SenseRelation"

  has_many :reverse_relations, :foreign_key => "child_id",
    :class_name => "SenseRelation"

  has_many :synset_senses
  has_many :synsets, through: :synset_senses

  def synset
    synsets.first
  end

  def as_json(options = {})
    data =  {
      :id => id,
      :lemma => lexeme.lemma,
      :sense_index => sense_index,
      :comment => comment || synset.definition || synset.comment || ""
    }

    if options[:synonyms]
      data[:synonyms] = synset.senses.map(&:as_json)
    end

    if options[:relations]
      sense_relations =
        relations.map { |r| r.as_json }

      synset_relations =
        synset.relations.map { |r| r.as_json }

      reverse_sense_relations =
        reverse_relations.map { |r| r.as_json(:reverse => true) }

      reverse_synset_relations =
        synset.reverse_relations.map { |r| r.as_json(:reverse => true) }

      synsets_hash = 
        Hash[synset_relations.map { |r| [r[:relation_id], r[:synset]] }]

      senses_hash = 
        Hash[sense_relations.map { |r| [r[:relation_id], r[:sense]] }]

      reverse_synsets_hash = 
        Hash[reverse_synset_relations.map { |r| [r[:relation_id], r[:synset]] }]

      reverse_senses_hash = 
        Hash[reverse_sense_relations.map { |r| [r[:relation_id], r[:sense]] }]

      data[:relations] = {
        synsets: synsets_hash,
        senses: senses_hash
      }

      data[:reverse_relations] = {
        synsets: reverse_synsets_hash,
        senses: reverse_senses_hash
      }
    end

    data
  end

end
