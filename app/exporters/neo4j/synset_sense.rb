module Neo4j
  class SynsetSense < Exporter

    def export_index(connection)
      nil
    end

    def export_queries(entity)
      queries = []

      if entity.sense.sense_index == 1
        queries << "MATCH (a:Sense { id: {sense_id} }), " +
        "(b:Synset { id: {synset_id} }) " +
        "MERGE (a)<-[r:synset_sense]-(b) "
      end

      queries << "MATCH (a:Singleton { id: {sense_id} }), " +
      "(b:Synset { id: {synset_id} }) " +
      "MERGE (a)-[r:relation { id: 0, weight: 0 }]->(b) "

      queries
    end

    def prepare_batch(entities)
      entities.flat_map do |entity|
        properties = export_properties(entity)
        export_queries(entity).map do |query|
          [:execute_query, query, properties]
        end
      end
    end

    def export_properties(entity)
      { synset_id: entity.synset_id, sense_id: entity.sense_id }
    end

    def source
      ::SynsetSense.includes(:sense)
    end

  end
end
