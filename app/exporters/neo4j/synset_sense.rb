module Neo4j
  class SynsetSense < Exporter
    
    def export_index(connection)
      if @connection.get_schema_index('Singleton').empty?
        @connection.create_schema_index('Singleton', "id")
        @connection.create_schema_index(source.name, "synset_id")
      end
    end

    def export_query(entity)
      "MATCH (a:Sense { id: {sense_id} }), " +
            "(b:Synset { id: {synset_id} }) " +
      "MERGE (a)-[r:belongs_to]->(b)"
    end

    def export_properties(entity)
      { synset_id: entity.synset_id, sense_id: entity.sense_id }
    end

    def source
      ::Sense
    end

    def export_properties(entity)
      entity.attributes.except(:external_id)
    end

  end
end
