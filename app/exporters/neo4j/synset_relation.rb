module Neo4j
  class SynsetRelation < Exporter

    EXPORT_QUERY = """
      MATCH (a:Synset { id: {parent_id} }),
      (b:Synset { id: {child_id} })
      MERGE (a)<-[r:relation { id: {relation_id}, weight: 1 }]-(b)
    """.gsub(/\s+/, ' ').strip.freeze

    HYPONYM_QUERY = """
      MATCH (a:Synset { id: {parent_id} }),
      (b:Synset { id: {child_id} })
      MERGE (a)<-[r:relation { id: {relation_id}, weight: 1 }]-(b)
      MERGE (a)<-[r2:hyponym]-(b)
    """.gsub(/\s+/, ' ').strip.freeze

    def export_index(connection)
      nil
    end

    def export_query(entity)
      if entity[:relation_id] == 10
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
