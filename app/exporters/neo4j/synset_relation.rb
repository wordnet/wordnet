module Neo4j
  class SynsetRelation < Exporter

    EXPORT_QUERY = """
      MATCH (p:Synset { id: {parent_id} }),
            (c:Synset { id: {child_id} })
      MERGE (c)-[r:relation { id: {relation_id}, weight: 1 }]->(p)
    """.gsub(/\s+/, ' ').strip.freeze

    HYPONYM_QUERY = """
      MATCH (p:Synset { id: {parent_id} }),
            (c:Synset { id: {child_id} })
      MERGE (c)-[r:relation { id: {relation_id}, weight: 1 }]->(p)
      MERGE (c)-[r2:hyponym]->(p)
    """.gsub(/\s+/, ' ').strip.freeze

    def export_index(connection)
      nil
    end

    def export_query(entity)
      if entity[:relation_id] == 10 || entity[:relation_id] == 173
        HYPONYM_QUERY
      else
        EXPORT_QUERY
      end
    end

    def export_properties(entity)
      {
        parent_id: entity.parent_id,
        child_id: entity.child_id,
        relation_id: entity.relation_id
      }
    end

    def source
      ::SynsetRelation
    end

  end
end
