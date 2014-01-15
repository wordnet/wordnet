module Neo4j
  class SenseRelation < Exporter

    EXPORT_QUERY = """
      MATCH (a:Singleton { id: {parent_id} }),
      (b:Singleton { id: {child_id} })
      MERGE (a)-[r:relation { id: {relation_id}, weight: 1 }]->(b)
    """.gsub(/\s+/, ' ').strip.freeze

    def export_index(connection)
      nil
    end

    def export_query(entity)
      EXPORT_QUERY
    end

    def export_properties(entity)
      {
        parent_id: entity.parent_id,
        child_id: entity.child_id,
        relation_id: entity.relation_id
      }
    end

    def source
      ::SenseRelation
    end

  end
end
