- static query strings
- multiple threads
- only relevant data in graph db
- indexes on Neo4j and MySQL

ap @neo.execute_query('MATCH (w:Word { lemma: "auto" })-[r:belongs_to]-(s:Synset)-[]->(s2:Synset) return w.id, s.id, s2.id limit 10')["data"]

- indexes on neo4j imported fields (merge)

- Proof you can't denormalize synsets:

match (c:Sense)-[:belongs_to]->(s2:Synset)--(s:Synset)<-[:belongs_to]-(b:Sense)
with s, count(c) as c1, count(b) as b1
return avg(c1 * b1)

2805.729094183261

(you need 3000 times storage, 500MB now).
