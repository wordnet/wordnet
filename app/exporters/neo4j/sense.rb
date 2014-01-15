module Neo4j
  class Sense < Exporter
    SENSE_EXPORT_QUERY = """
      MERGE (g:Synset:Singleton { id: {id} })
      MERGE (n:Sense { id: {id} })
      ON CREATE SET 
      n.domain_id = {domain_id},
      n.comment = {comment},
      n.sense_index = {sense_index},
      n.language = {language},
      n.synset_id = {synset_id},
      n.lemma = {lemma}
      ON MATCH SET
      n.domain_id = {domain_id},
      n.comment = {comment},
      n.sense_index = {sense_index},
      n.language = {language},
      n.synset_id = {synset_id},
      n.lemma = {lemma}
      WITH g, n
      MERGE (g)-[r:synset_sense]->(n)
    """.gsub(/\s+/, ' ').strip.freeze

    def source
      ::Sense
    end

    def export_index!
      if @connection.get_schema_index("Sense").empty?
        @connection.create_schema_index("Sense", "id")
      end

      if @connection.get_schema_index("Singleton").empty?
        @connection.create_schema_index("Singleton", "id")
      end
    end

    def prepare_batch(entities)
      entities.map do |entity|
        [:execute_query,
         SENSE_EXPORT_QUERY, entity.attributes.except(:external_id)]
      end
    end
  end
end
