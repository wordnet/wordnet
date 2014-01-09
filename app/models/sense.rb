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
      :lemma => lemma,
      :sense_index => sense_index,
      :language => language,
      :domain_id => domain_id,
      :comment => comment
    }

    if options[:synonyms]
      data[:synonyms] = synset.senses.map(&:as_json)
    end

    if options[:relations]
      data[:relations] =
        (relations.map { |r| r.as_json } +
        synset.relations.map { |r| r.as_json }).
        group_by { |r| r[:relation_id] }

      data[:reverse_relations] =
        (reverse_relations.map { |r| r.as_json(:reverse => true) } +
        synset.reverse_relations.map { |r| r.as_json(:reverse => true) }).
        group_by { |r| r[:relation_id] }
    end

    data
  end

end
