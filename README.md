# Wordnet

Open Source browsing application for Wordnet database

## Requirements

- Ruby 2.1.0
- PostgreSQL 9
- Neo4J 2
- MySQL (for WordnetSQL import)

## Installation

```
# Load wordnet database to MySQL

rbenv install 2.1.0
rbenv use 2.1.0
bundle install

bin/rake db:create db:migrate
bin/rake wordnet:import
```

## Ubuntu 12.04 deployment

Video: [https://www.youtube.com/watch?v=kJVyO9I173o](https://www.youtube.com/watch?v=kJVyO9I173o).

- Create hosting account (e.g. digitalocean)
- Create user with sudo permissions
- Remember to `ssh-copy-id` your public key to this new user account
- Add your public key to `data/playbook.yml
- Ensure ansible is installed on your machine
- Run `bin/setup-host USER@HOST:PORT` command to setup your server. It installs:
  - common tools
  - ruby, java
  - mysql, postgresql, neo4j
  - deployment framework
- ssh to wordnet@HOST and run `./deploy` script
- download mysql database to server
- import database to mysql via "mysql -D wordnet < wordnet.sql"
- go to current deployment location (cd production/current) and run:
  - `RAILS_ENV=production bin/rake wordnet:import` (imports mysql to postgresql)
  - `RAILS_ENV=production bin/rake wordnet:export` (exports postgresql to neo4j)
  - `RAILS_ENV=production bin/rake wordnet:translations` (generates translations)
  - `RAILS_ENV=production bin/rake wordnet:stats` (generates statistics)
- to change url prefix of application:
  - add `URL_ROOT=/wordnet` to `.env` file in application's deployment directory
  - touch tmp/restart.txt to restart an application

```

## Project overview

[Słowosieć][1] is a Polish equivalent of Princeton Wordnet, a lexical database of word senses and relations between them.

The purpose of this document is to describe a successful effort of making the web interface of Polish Wordnet more performant and user-friendly. In particular we'll elaborate on developed architecture, used components, and database designs.

The front-end and back-end of application were rebuilt from scratch. As as result the browsing latency dropped from 30 seconds in some cases to 110ms on average.

## Architecture

Following decisions has been made:

* Data is stored in normalised form using relational database
* Data is indexed and queried using graph database
* Data is rendered on client-side using templates
* Data is loaded through a well-crafted API endpoint

Given [multiple issues with MySQL database][2] and [performance issues with handling UUIDs][17], the [PostgreSQL][3] were chosen as relational database backend. This has an additional advantage of storing data in Hstore and Array types (where sensible), avoiding unnecessary `JOIN` statements for data retrieval.

[Neo4J][4] has been chosen as relational database backend. The main reasons included being open-source, mature, and reliable graph store. Neo4J is one of the few graph databases providing declarative way of querying data, using [Cypher][5] language (similar in some ways to SQL).

On front-end an [Angular.js][6] framework is used. It is relatively new, but popular product developed and maintained by Google. It allows for easy decoupling of application logic and template rendering using unique concepts of [directives, services, and controllers][7].

[Rails 4][8] web-framework is used for both API endpoint, and serving front-end. Rails is mature software, allowing for robust development of modern web applications. Made in [Ruby][9], allows us to use use tens of thousands of [Ruby Gems][10], significantly boosting the development.

API allows for disjoint development of front-end and back-end.

## Other technologies used

Experience made us choose following set of tool for application development:

* [CoffeeScript][11] replacing plain JavaScript
* [SASS][12] replacing plain CSS stylesheets
* [SLIM][13] for rendering front-end HTML markup

## Definitions

- [Lexeme][14] - unit of lexical meaning that exists regardless of the number of inflectional endings it may have or the number of words it may contain (e.g. run, ran, runs)
- [Lemma][15] - particular form of a lexeme that is chosen by convention to represent a canonical form of a lexeme (e.g. run)
- [Sense][16] - a Lexeme associated with particular meaning. Each Lexeme can have multiple Senses. In Wordnet each Sense is associated with number to easily distinguish (e.g. I can write `run 4` meaning an unbroken series of events, or `run 5` meaning the act of running)
- [Synset](https://en.wikipedia.org/wiki/Synonym_ring) - a set of Senses (not Lexemes) with similar meaning, i.e. synonyms (e.g. `run 2` forms Synset with following Senses: `bunk 3`, `escape 6`, turn `tail 1`).
- [Sense Relation](https://academic.cuesta.edu/acasupp/as/507.HTM) - a relationship between two Senses, i.e. relationship between two particular meanings of words (e.g. `big 1` is antonym of `little 1`)
- Synset Relation - a relationship between two Synsets, i.e. relationship between two groups of Senses (e.g. `Synset { act 10, play 25 }` is hyponym of `Synset { overact 1, overplay 1 }`).
- Relation Type - each SenseRelation and SynsetRelation has its type, it can be among others: antonym, hyponym, hyperonym, meronym, ...

In summary: Each Lexeme is represented by Lemma. Each Lexeme has multiple Senses. Each Sense forms Synset with other Senses. Each Sense can be in SenseRelation to other Senses. Each Synset can be in SynsetRelation to other Synsets. Each Relation has its own RelationType.

Above concepts of Wordnet are modelled in application in following way:

![Class Diagram](https://raw.githubusercontent.com/wordnet/wordnet/master/doc/class_diagram.png)


## Relational Database

Introducing Relational Database as primary store had two purposes:
1. Reliably and economically storing data in normalised form
2. Ability to use de-normalised graph database as index

The data is imported to normalised form from Polish Wordnet, but the  process allows for importing arbitrary Wordnet-alike database.

Non-conventionally the primary keys of database tables are UUIDs, instead of auto-incrementing values. It has few advantages:
- Plays well with graph databases, each node has its own unique ID
- UUIDs for records can be generated by application code what makes  inserting interconnected data into the database easier & performant.
- Makes replication of relational database trivial
- Allows for easy merging of two databases with same schema

The overall schema closely reassembles concepts described earlier:

### senses

* `id`: The UUID identifier
* `synset_id`:  The UUID of connected Synset
* `external_id`:  The ID from external database, used for importing
* `lemma`: The lemma of Lexeme that Sense belongs to (e.g. car)
* `sense_index`: The index of sense in context of its Synset (e.g. 1)
* `comment`: The short comment, used in UI (e.g. transporting machine)
* `language`: Currently can be `en_GB` or `pl_PL`
* `part_of_speech`: The part of speech of Sense (noun etc.)
* `domain_id`: The ID of the Domain of Sense (not used yet)

### synsets

* `id`: The UUID identifier
* `external_id`:  The ID from external database, used for importing
* `comment`: The short comment by Słowosieć, used in UI
* `definition`: The short comment by Princeton Wordnet, used in UI
* `examples`: The examples of usage of synset from Princeton Wordnet

### relation_types

* `name`: Name of the relation
* `reverse_relation`: Name of reverse relation (see: normalisation)
* `parent_id`: Name of parent RelationType (inheritance-like)
* `priority`: It is used for sorting relation types in UI (lower-better)
* `description`: Description of the relation (not used yet)

### sense\_relations and synset\_relations

* `parent_id`: UUID of base sense (or synset)
* `child_id`: UUID of of related sense (or synset)
* `relation_id`: UUID of relation in which child is toward parent (e.g. UUID hyponymy relation means child is hyponym of parent)

### Normalisation of Relations
Imported relations are normalised in few ways:

1. For reverse relation types we leave only one relation type (by convention the one where where are more children than parents, e.g. hyponymes, not hyperonymes).
2. The name of removed reverse relation is assigned to reverse_name
3. Name and reverse_name are in plural form for for UI purposes
4. Even name has it’s parent, the name describes full relation type name (for example “Meronymes (place)”, not “place”)

![Relations](https://github.com/wordnet/wordnet/blob/master/doc/reverse_relation.png)

## Graph Database

![Graph Database](https://github.com/wordnet/wordnet/blob/master/doc/graph_database.png)
Graph database has slightly different structure than relational database. Most importantly Sense and Synset nodes don’t contain any data except their IDs. The relationships of type `relation` exist only between Synset and Senses. All data displayed in UI columns is hold in Data nodes.

Each Synset and each Sense is represented by connected Data node in UI.

Data node holds following data from Sense model:
* lemma
* sense_index
* comment
* language
* part_of_speech
* domain_id

## Importing data from external Wordnets

Wordnet uses internal, normalised representation of database. The normalised structure is defined in Relational Database section.

The data mapping is done by 5 classes inherited from Importer class:

* WordnetPl::RelationType
* WordnetPl::Sense
* WordnetPl::Synset
* WordnetPl::SenseRelation
* WordnetPl::SynsetRelation

Each class is responsible for importing data to corresponding models.

Importer class processes data in batches for performance reasons. It handles progress bar rendering, parallelising import process, and synchronising writes. It expects following methods to be defined in descendants:

* `total_count`: The total count of items to be imported
* `load_entities(limit, offset)`: This method should load `limit` records from external database with given `offset` and return hash consumed later by `process_entities!` method
* `process_entities!(entities)`: This method is responsible for processing data returned from `load_entites` and passing them to `persist_entities!` method described below

`persist_entities!(table_name, collection, unique_attributes)` uses [Upsert][18] method to insert or update data in database in performant way. It accepts table in database where the record should be inserted/updated, the actual `collection` of records as array of hashes where keys are column names (see relational database schema) and values are row values. The `unique_attributes` is an array of column names that upsert method will use for selecting data to merge (usually “id”, but can be for example `[“parent_id”, “child_id”]` for relations.

Import process can be triggered by issuing command:

```
bin/rake wordnet:import
```

The source database defaults to `mysql2://root@localhost/wordnet`, but you can change it by passing `SOURCE_URL` environment variable.

## Exporting to Neo4J index

The same way importer classes inherit from Importer, exporter classes inherit from Exporter. The are only 4 exporter classes:

* Neo4J::Sense
* Neo4J::Synset
* Neo4J::SenseRelation
* Neo4J::SynsetRelation

Each exporter is supposed to define 2 methods:

* `export_index!`: that ensures at the beginning of export that proper indexes are present in Neo4J database
* `process_batch(entities)`: method that accepts array of entity hashes, just like `process_entities!` and returns array of queries to execute in batch request by [Neography][19] gem.

Export process can be triggered by issuing command:

```
bin/rake wordnet:export
```

The destination defaults to `http://127.0.0.1:7474`, but you can change it by passing `NEO4J_URL` environment variable.

## Deployment

Application is supposed to be run on at least 3 servers:

1. Application server
2. PostgreSQL server
3. Neo4J server

On application server the Rails application should be deployed, using any method. At least Node.js, Ruby 2.0, and development libraries of Postgresql and Mysql are required to be installed on system.

 The addresses of PostgreSQL database and Neo4J database are passed by `NEO4J_URL` environment variable, and database information is configured in `config/database.yml`.

The assets need to be precompiled before deploying app on production:

```
RAILS_ENV=production bin/rake assets:precompile
```

The server can be started by hand with:

```
RAILS_ENV=production bin/rails server --port 80
```

Or by tool you choose (Capistrano or other).

## License

Wordnet is released under the MIT License.

[1]: http://plwordnet.pwr.wroc.pl/wordnet/
[2]: http://sql-info.de/mysql/gotchas.html
[3]: http://www.postgresql.org/
[4]: http://www.neo4j.org/
[5]: http://www.neo4j.org/learn/cypher
[6]: http://angularjs.org/
[7]: http://docs.angularjs.org/guide/concepts
[8]: http://rubyonrails.org/
[9]: https://www.ruby-lang.org/
[10]: http://rubygems.org/
[11]: http://coffeescript.org/
[12]: http://sass-lang.com/
[13]: http://slim-lang.com/
[14]: https://en.wikipedia.org/wiki/Lexeme
[15]: https://en.wikipedia.org/wiki/Lemma_(morphology)
[16]: https://en.wikipedia.org/wiki/Lexical_item
[17]: http://www.codeproject.com/Articles/388157/GUIDs-as-fast-primary-keys-under-multiple-database
[18]: https://github.com/seamusabshere/upsert
[19]: https://github.com/maxdemarzi/neography
