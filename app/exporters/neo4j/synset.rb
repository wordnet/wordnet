module Neo4j
  class Synset < Exporter
    
    def export_index(connection)
      nil
    end

    def source
      ::Synset
    end


    def export_query(entity)
      "MERGE (n:Synset { id: {id} })"
    end

    def export_properties(entity)
      { id: entity.id }
    end
  end
end
