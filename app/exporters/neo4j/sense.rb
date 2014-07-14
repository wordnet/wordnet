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
      n.part_of_speech = {part_of_speech},
      n.lemma = {lemma}

      ON MATCH SET
      n.domain_id = {domain_id},
      n.comment = {comment},
      n.sense_index = {sense_index},
      n.language = {language},
      n.part_of_speech = {part_of_speech},
      n.lemma = {lemma}

      WITH g, n

      MERGE (g)<-[r:synset]-(n)
    """.gsub(/\s+/, ' ').strip.freeze

    SYNSET_SENSE_EXPORT_QUERY = """
      MATCH (sy:Synset { id: {synset_id} }), (se:Sense { id: {sense_id} })
      MERGE (sy)<-[r:synset]-(se)
    """.gsub(/\s+/, ' ').strip.freeze

    SYNSET_RELATION_EXPORT_QUERY = """
      MATCH (sy:Synset { id: {synset_id} }), (se:Singleton { id: {sense_id} })
      MERGE (se)-[r:relation { id: 0, weight: 0 }]->(sy)
    """.gsub(/\s+/, ' ').strip.freeze

    def source
      ::Sense
    end

    def export_index!
      if @connection.get_schema_index("Sense").empty?
        @connection.create_schema_index("Sense", "id")
        @connection.create_schema_index("Sense", "lemma")
      end

      if @connection.get_schema_index("Singleton").empty?
        @connection.create_schema_index("Singleton", "id")
      end
    end

    def prepare_batch(entities)
      entities.map do |entity|
        [:execute_query,
         SENSE_EXPORT_QUERY, entity.attributes.except(:external_id)]
      end + entities.select { |e| e[:core] }.map do |entity|
        [:execute_query,
          SYNSET_SENSE_EXPORT_QUERY, { sense_id: entity[:id], synset_id: entity[:synset_id] }]
      end + entities.map do |entity|
        [:execute_query,
          SYNSET_RELATION_EXPORT_QUERY, { sense_id: entity[:id], synset_id: entity[:synset_id] }]
      end
    end
  end
end
