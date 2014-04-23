class Sense < ActiveRecord::Base

  belongs_to :lexeme
  belongs_to :synset

  has_many :related, :foreign_key => "parent_id",
    :class_name => "SenseRelation"

  has_many :reverse_related, :foreign_key => "child_id",
    :class_name => "SenseRelation"

  def fetch_related
    neo = Neography::Rest.new(Figaro.env.neo4j_url)
    query = """
      match (s:Singleton{ id: {id} }),
            (s-[:relation*0..1 { weight: 0 }]->(h:Synset)),
            (h<-[r:relation { weight: 1 }]-(i:Synset)),
            (i<-[r2:synset]-(target:Sense))
      return {
        relation_id: r.id,
        language: target.language,
        target_type: lower(head(labels(i))),
        senses: collect({
          id: target.id,
          lemma: target.lemma,
          comment: target.comment,
          part_of_speech: target.part_of_speech,
          sense_index: target.sense_index
        })
      }
    """.strip_heredoc

    neo.execute_query(
      query, id: id
    )["data"].map(&:first)
  end

  def fetch_reverse_related
    neo = Neography::Rest.new(Figaro.env.neo4j_url)
    query = """
      match (s:Singleton{ id: {id} }),
            (s-[:relation*0..1 { weight: 0 }]->(h:Synset)),
            (h-[r:relation { weight: 1 }]->(i:Synset)),
            (i<-[r2:synset]-(target:Sense))
      return {
        relation_id: r.id,
        language: target.language,
        target_type: lower(head(labels(i))),
        senses: collect({
          id: target.id,
          lemma: target.lemma,
          comment: target.comment,
          part_of_speech: target.part_of_speech,
          sense_index: target.sense_index
        })
      }
    """.strip_heredoc

    neo.execute_query(
      query, id: id
    )["data"].map(&:first)
  end

  def as_json(options = {})
    data =  {
      :id => id,
      :lemma => lemma,
      :sense_index => sense_index,
      :language => language,
      :domain_id => domain_id,
      :part_of_speech => part_of_speech,
      :comment => comment
    }

    if options[:extended]
      data[:homographs] = Sense.where(
        "LOWER(lemma) like LOWER(?) AND language = ?",
        lemma, language
      ).order(
        sense_index: :asc
      ).select(:id).map(&:id)

      data[:synset] = synset.as_json(without: id)
      data[:outgoing] = fetch_related
      data[:incoming] = fetch_reverse_related
    end

    data
  end

end
