class Sense < ActiveRecord::Base

  belongs_to :lexeme
  belongs_to :synset

  has_many :relations, :foreign_key => "parent_id",
    :class_name => "SenseRelation"

  has_many :reverse_relations, :foreign_key => "child_id",
    :class_name => "SenseRelation"

  def fetch_relations
    neo = Neography::Rest.new
    query = """
      match (s:Singleton{ id: {sense_id} }),
            (s-[:relation*0..1 { weight: 0 }]->(h:Synset)), 
            (h-[r:relation { weight: 1 }]->(i:Synset)),
            (i-[r2:synset_sense]->(target:Sense))
      return {
        relation_id: r.id,
        senses: collect({
          id: target.id,
          lemma: target.lemma,
          comment: target.comment,
          sense_index: target.sense_index
        })
      }
    """.strip_heredoc

    neo.execute_query(
      query, sense_id: id
    )["data"].map(&:first)
  end

  def fetch_reverse_relations
    neo = Neography::Rest.new
    query = """
      match (s:Singleton{ id: {sense_id} }),
            (s-[:relation*0..1 { weight: 0 }]->(h:Synset)), 
            (h<-[r:relation { weight: 1 }]-(i:Synset)),
            (i-[r2:synset_sense]->(target:Sense))
      return {
        relation_id: r.id,
        senses: collect({
          id: target.id,
          lemma: target.lemma,
          comment: target.comment,
          sense_index: target.sense_index
        })
      }
    """.strip_heredoc

    neo.execute_query(
      query, sense_id: id
    )["data"].map(&:first)
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
      data[:relations] = fetch_relations
      data[:reverse_relations] = fetch_reverse_relations
    end

    data
  end

end
