# Wordnet

Open Source engine for Wordnet databases.

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

## License

As Rails, this project is [MIT-licensed](http://opensource.org/licenses/mit-license.php). As usual, you are awesome.
