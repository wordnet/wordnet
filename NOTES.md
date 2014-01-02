- static query strings
- multiple threads
- only relevant data in graph db
- indexes on Neo4j and MySQL

ap @neo.execute_query('MATCH (w:Word { lemma: "auto" })-[r:belongs_to]-(s:Synset)-[]->(s2:Synset) return w.id, s.id, s2.id limit 10')["data"]

- indexes on neo4j imported fields (merge)
