class Sense < ActiveRecord::Base

  include Exportable

  belongs_to :lexeme
  belongs_to :synset

  has_many :relations, :foreign_key => "parent_id",
    :class_name => "SenseRelation"

  has_many :reverse_relations, :foreign_key => "child_id",
    :class_name => "SenseRelation"

  def fetch_relations
    neo = Neography::Rest.new
    query = """
      match (s:Sense)-[:belongs_to]->(:Synset)-[r:relation]->(:Synset)<-[:belongs_to]-(target:Sense)
      where s.id = {sense_id}
      with s, r, collect({
        id: target.id,
        lemma: target.lemma,
        comment: target.comment,
        sense_index: target.sense_index
      }) as senses
      return collect({
        relation_id: r.id,
        senses: senses
      })
      union
      match (s:Sense)-[r:relation]->(target:Sense)
      where s.id = {sense_id}
      with s, r, collect({
        id: target.id,
        lemma: target.lemma,
        comment: target.comment,
        sense_index: target.sense_index
      }) as senses
      return collect({
        relation_id: r.id,
        senses: senses
      })
    """.strip_heredoc

    neo.execute_query(
      query, sense_id: id
    )["data"][0]
  end

  def fetch_reverse_relations
    neo = Neography::Rest.new
    query = """
      match (s:Sense)-[:belongs_to]->(:Synset)<-[r:relation]-(:Synset)<-[:belongs_to]-(target:Sense)
      where s.id = {sense_id}
      with s, r, collect({
        id: target.id,
        lemma: target.lemma,
        comment: target.comment,
        sense_index: target.sense_index
      }) as senses
      return collect({
        relation_id: r.id,
        senses: senses
      })
      union
      match (s:Sense)<-[r:relation]-(target:Sense)
      where s.id = {sense_id}
      with s, r, collect({
        id: target.id,
        lemma: target.lemma,
        comment: target.comment,
        sense_index: target.sense_index
      }) as senses
      return collect({
        relation_id: r.id,
        senses: senses
      })
    """.strip_heredoc

    neo.execute_query(
      query, sense_id: id
    )["data"][0]
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
      data[:relations] = fetch_relations[0]
      data[:reverse_relations] = fetch_reverse_relations[0]
    end

    data
  end

  def self.export_index(connection)
    connection.create_schema_index(self.name, "id")
    connection.create_schema_index(self.name, "synset_id")
  end

  def self.export_query
    "MERGE (n:#{self.name} { id: {id} }) " +
    "ON CREATE SET " +
    "n.domain_id = {domain_id}, " +
    "n.comment = {comment}, " +
    "n.sense_index = {sense_index}, " +
    "n.language = {language}, " +
    "n.synset_id = {synset_id}, " +
    "n.lemma = {lemma} " +
    "ON MATCH SET " +
    "n.domain_id = {domain_id}, " +
    "n.comment = {comment}, " +
    "n.sense_index = {sense_index}, " +
    "n.language = {language}, " +
    "n.synset_id = {synset_id}, " +
    "n.lemma = {lemma}"
  end

  def self.export_properties(entity)
    entity.attributes.except(:external_id)
  end

end
