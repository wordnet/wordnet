class Sense < ActiveRecord::Base

  belongs_to :lexeme
  belongs_to :synset

  has_many :related, :foreign_key => "parent_id",
    :class_name => "SenseRelation"

  has_many :reverse_related, :foreign_key => "child_id",
    :class_name => "SenseRelation"

  # Take lowest synset_index in groups by synset_id and mark it as core. 
  # Synset cores are representations of matching synsets.
  def self.label_sense_cores!
    Sense.update_all('sense_core = true', "id in (#{
      Sense.
        select('distinct on (LOWER(lemma), language, part_of_speech) id').
        order('LOWER(lemma), language, part_of_speech, sense_index').
        to_sql
    })")
  end

  # Take lowest sense_index in groups by lemma, language, and part_of_speech
  # and mark it as core. Sense cores are representations of connected lemma.
  def self.label_synset_cores!
    Sense.update_all('synset_core = true', "id in (#{
      Sense.
        select('distinct on (synset_id) id').
        order('synset_id, synset_index').
        to_sql
    })")
  end

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
          domain_id: target.domain_id,
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
          domain_id: target.domain_id,
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
        "LOWER(lemma) like LOWER(?) and part_of_speech = ?",
        lemma, part_of_speech
      ).order(
        language: :desc,
        sense_index: :asc
      ).as_json

      data[:synset] = synset.as_json(without: id)
      data[:definition] = definition
      data[:examples] = examples || synset.examples || []
      data[:outgoing] = fetch_related
      data[:incoming] = fetch_reverse_related
    end

    data
  end

end
