# Wordnet

Open Source browsing application for Wordnet database

## Requirements

- Ruby 2.1.0
- PostgreSQL 9
- Neo4J 2.1.2 (at least this version)
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

```
apt-get update && apt-get upgrade
apt-get install -y git make curl software-properties-common
apt-get install -y python-software-properties
curl -s https://get.docker.io/ubuntu/ | sudo sh
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

![Class Diagram](http://d.pr/i/Kl6N.png)


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

![Relations](http://d.pr/i/n3UN.png)

## Graph Database

![Graph Database](http://d.pr/i/O1NQ.png)
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

## Front-end

### Disclaimer

Most of the described topics require at least some knowledge of web development technologies: HTML, CSS and JavaScript. I realize that reading this documentation might not result in proper understanding of the used stack.

If I was to point to a single resources to get started, I’d recommend the official [Angular.js tutorial](http://docs.angularjs.org/tutorial). Of all used technologies, the framework may be the most confusing to newcomers (like it was to me in the past). It’s an excellent framework which is also *exceptionally* well-documented.

### Technology Stack

This the list of all technologies, languages, third-party components, and other notions that were used to build Wordnet’s front-end. Each one of them is open source and available for free.

#### Technologies

* [Ruby on Rails](http://rubyonrails.org) (with [Sprockets](https://github.com/sstephenson/sprockets))
* HTML, CSS, JavaScript

#### Precompiled Languages

* [Slim](http://slim-lang.com)
* [Sass](http://sass-lang.com)
    * [Compass](http://compass-style.org)
* [CoffeeScript](http://coffeescript.org)

#### Frameworks and Libraries

* [Lodash](http://lodash.com)
* [Angular.js](http://angularjs.org)
    * [UI Bootstrap](http://angular-ui.github.io/bootstrap/)

#### Other

* [Rails Assets](http://rails-assets.org)
* [BEM](http://csswizardry.com/2013/01/mindbemding-getting-your-head-round-bem-syntax/)
* [SPA](http://en.wikipedia.org/wiki/Single-page_application)
* [Git](http://git-scm.com)


### Assets

First of all, there are 2 main directories of our interest: `app/assets` and `app/views`.

By default, assets are grouped into 3 self-explanatory categories:

```
app/assets
├── images
├── javascripts
└── stylesheets
```

All assets served by Rails automatically go through the asset pipeline called *Sprockets.* This is the engine responsible for allowing us to use Sass instead of *raw* CSS and CoffeeScript instead of JavaScript (those are our two choices of many available) without having to perform any compilation manually.

Sprockets has more advantages which are out of the scope of this documentation. Two of those are worth mentioning, though:

#### Production Mode

During deployment of the application into production mode, both stylesheets and scripts are concatenated into single files and compressed in order to make them load faster when they are requested by the browser (by saving the size of assets and the number of HTTP requests).

#### Path Resolution

If a path in a `require` or `@import` statement doesn’t point to any *tangible* resource (and no error is thrown), Sprockets resolve the path to the asset inside a gem. Gem is a third-party Ruby package that *can* contain assets. We make use of some asset gems inside the application, mainly for JavaScript components.

### Views

A view is an HTML template usually filled by Rails with content based on the current route (the URL). In Wordnet’s case, the entire content is provided by JavaScript dynamically (via the API that the application serves), so all what the Rails views do is just to compose templates that will be used by Angular.js.

```
app/views
├── errors
├── home
├── layouts
└── shared
    └── templates
```

The default view (used at the root URL, `/`) can be found at`home/index.slim`. When rendered, it’s wrapped by the layout, `application.slim`. These two files make use of all partial views from the `shared` directory. The rest of the application views are used for error pages (and are provided by Rails).

All of the aforementioned view names end with `.slim`, because we use [Slim templates](http://slim-lang.com) instead of raw HTML. Their syntax is shorter and looks cleaner.

## Stylesheets

The main stylesheet that defines the look of Wordnet is `application.sass` (located in `app/assets/stylesheets`), which itself includes a few smaller stylesheets called partials.

### Preprocessing and Postprocessing

The extension of the file is `.sass` (and not `.css`), because we use [Sass](http://sass-lang.com) to preprocess it. The language provides a [number of features](http://sass-lang.com/guide) that allow us to write [DRY](http://pl.wikipedia.org/wiki/DRY)er code much easier than CSS.

Rails compiles `.sass` files to `.css` out of the box.

Additionally, all stylesheets are postprocessed by [Autoprefixer](https://github.com/ai/autoprefixer), which automatically adds [vendor prefixes](http://reference.sitepoint.com/css/vendorspecific) where necessary. This process is completely *invisible* and lets the developer focus on the code and not maintaining the compatibility of single CSS properties.

### Partial Structure

A stylesheet is indicated to be a partial when its name starts with `_` (the underscore). Regardless of that, when including partials using the `@import` directive, Sass allows for omitting the character as well as the extension from the file path in order to write cleaner code. This is the content of `application.sass`:

```sass
@import "application/variables"
@import "application/mixins"
@import "application/fonts"
@import "application/base"
@import "application/placeholders"
@import "application/modules/*"
@import "application/utilities"
@import "application/vendor"
@import "application/shame"
```

When `application/base` is `@import`’ed , Sass looks for Unix-like `{_,}base.{css,scss,sass}` file pattern inside `application` directory and takes the first match. The language also supports globbing known from Unix environments.

Let’s go through the hierarchy of imported partials:

#### Variables

This is the configuration partial that stores all variables. It contains information like the width or the background color of a side column, the height of the top bar, etc.

#### Mixins

Even though the file is called `_mixins.sass`, it includes not only Sass mixins, but functions too.

`application.sass` makes use of selected [Compass helpers](http://compass-style.org/reference/compass/helpers/). Compass is a collection of useful mixins and functions for Sass, so the third-party component is `@import`’ed  in this partial.

There are no separated partial scopes, so the language makes all mixins available inside the entire stylesheet, including all of its partials.

#### Fonts

We’re using a custom (as in unavailable by default) font for the text, [Open Sans](http://en.wikipedia.org/wiki/Open_Sans) which is considered a modern typeface and—as the name may suggest—it’s open and free.

This partial contains only the `@font-face` rules that specify *which* webfonts will be used.

#### Base

This is the place where *bare* HTML tags are styled: `html`, `body`, and so on. It also indicates *where* Open Sans is used.

It’s the CSS reset which strips out the styles applied by browser engines. Different browsers use different defaults—that’s why it’s a common technique to make them consistent.

#### Placeholders

Placeholders are a more advanced topic. They are [special reusable selectors](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#placeholders) (denoted by `%` at the beginning) which contain styles that can be extended by regular selectors.

Placeholders keep the code DRYer. This is very simple example of two equivalent stylesheets (please note that this is still Sass, and not generated CSS):

```sass
%bright-links-on-dark-background
  background: darkgray
  color: lightgray

  a
    color: white

.top
  @extend %bright-links-on-dark-background
  background: black

.bottom
  @extend %bright-links-on-dark-background
```

```sass
.top
  background: darkgray
  color: lightgray

  a
    color: white

.bottom
  background: darkgray // will be overwritten
  background: black
  color: lightgray

  a
    color: white
```

This partial has to be defined before all modules, so that some of rules could be overwritten (if necessary, rarely).

#### Modules

The entire page is built from small reusable components defined in `modules` directory:

```
modules
├── _autocomplete.sass
├── _definition.sass
├── _item.sass
├── _layout.sass
├── _list.sass
├── _modal.sass
├── _path.sass
└── _top.sass
```

* A module in the Wordnet stylesheets is an independent unit which uses [BEM syntax](http://csswizardry.com/2013/01/mindbemding-getting-your-head-round-bem-syntax/).
* Modules can contain other modules, and separate modules can also be interlaced with each other *in the markup.*
* Modules can contain definitions of placeholders or variables if it doesn’t make sense to use them anywhere else.
* With the exception of `_layout.sass`, file name reflects the module name.
* Modules are `@import`’ed using Unix-like globbing, because their order in the resultant stylesheet doesn’t really matter.

This is how the main interface can be broken down into modules:

![](http://imgur.com/gnm3f53.png)

Worth noting:

* Search suggestions are also the part of `.autocomplete`.
* The hyponyms path window consists of a `path` inside `modal`.
* Layout is a special case: as the name suggests, it’s related to the page scaffolding. It contains 2 separate tiny modules: `.wrapper` and `.grid`. Categorizing them under one term, `layout`, seems appropriate.

#### Utilities

A collection of simple classes used throughout the page that don’t make a component due to their lack of cohesion. A class name indicates a presentational *utility* when it begins with `.u__`. This is the only deviation from BEM class naming (there is no `.u` alone).

#### Vendor

This partial is not related to aforementioned vendor prefixes. Instead, it’s a collection of styles that apply to third-party components (like elements added by any of Angular.js modules).

#### Shame

Hacks or inelegant solutions shouldn’t get unnoticed within the thick of long stylesheets. That’s why [this partial](http://csswizardry.com/2013/04/shame-css/) exists. It collects those parts that need rethinking.

The code is not necessarily wrong—it just *could get better.* At the time of writing, this file contains one selector I’m not happy of (which I consider a small success).

## JavaScripts

Wordnet is a single-page application, which makes it feel more like a desktop app than a traditional website.

### Single-page Application

The term characterizes a website which:

1. Downloads all initial pieces of content along with the required assets (scripts and stylesheets) once as the page has been requested by the browser.
2. Loads additional data on demand over [XHR](http://pl.wikipedia.org/wiki/XMLHttpRequest).

This is the true *secret* behind Wordnet’s perceived performance: the website isn’t reloaded—only the data is. Combine this with fast and robust back-end, and the user experience automatically gets better.

Single-page applications usually meet with an array of challenges related to conventions, overall application structure, using low-level APIs (like XHR), *not* breaking browser’s back button, and so on. This is the reason why we opted for a modular and well-documented framework that solves most of those issues, [Angular.js](http://angularjs.org).

### Angular.js

Angular.js is different than other client-side (running in the browser) JavaScript frameworks. In a way, it *extends* HTML, which was initially designed for creating static, stateless documents, instead of abstracting away parts of it (as almost all libraries currently do).

The main reasons we use Angular.js are [its templates](http://docs.angularjs.org/tutorial/step_02) combined with [two-way data binding](http://docs.angularjs.org/tutorial/step_04) which keeps them (as well as and handling them) lightweight.

### CoffeeScript

Instead of *raw* JavaScript, we use [CoffeeScript](http://coffeescript.org). The language provides cleaner Ruby-like syntax and a few sugars. Since Rails is a Ruby project, CoffeeScript is almost always the choice of rubyists working with web applications.

Files with the `.coffee` extension are compiled to `.js` scripts. Thanks to this fact, CoffeeScript components can depend on those written in raw JavaScript.

As in the case of Sass, Rails supports CoffeeScript out of the box.

### JavaScripts Structure

Similarly to stylesheets, the main JavaScript file is `application.coffee` and can be found in `app/assets/javascript`.

The file begins with the following:

```coffee
#= require lodash
#= require angular
#= require angular-bootstrap
#= require angular-route
#= require_self
#= require_tree ./factories
#= require_tree ./controllers
#= require_tree ./directives
#= require_tree ./filters
```

JavaScript (and therefore CoffeeScript) doesn’t support partials nor a native `@import`-like statement, so this is where Sprockets directives help.

All the `require` statements that appear before `require_self`, prepend the current file with the contents of the pointed files, and those after—append to it. Alternatively, `require_tree` can be used, which includes the all `.js` and `.coffee` files in the given directory. All file extensions can be omitted.

In this case, `application.coffee` includes [Lodash](http://lodash.com) (the utility library), Angular.js and its 2 third-party components (all of them packaged in gems using [Rails Assets](http://rails-assets.org)), then `itself`, and a few files found in `javascripts`’ subdirectories.

### Angular.js Structure

Angular assets are divided into 5 groups:

#### Configuration

```coffee
angular.module('wordnet', ['ngRoute', 'ui.bootstrap'])
```

This is where the Angular application is initialized. All its dependencies are referenced in an array given as the second argument to `angular.module`.

That line can be found in `application.coffee`. The file also contains the configuration of the [router](http://docs.angularjs.org/tutorial/step_07) responsible for updating the current URL as the content is changed.

[`ui.bootstrap`](http://angular-ui.github.io/bootstrap/) is another collection of reusable components. Wordnet makes use of two from the package: `typeahead` that powers the search field (`.autocomplete`) and `modal` behind the hyponyms path view.

#### Factories

Consider a factory as a *data factory.* It’s a module responsible for delivering data, usually by making asynchronous calls to API to fetch JSON-formatted data.

The application introduces 4 factories:

* `getRelations`: returns all possible relations, with their properties. This factory is called right after the page has been loaded.
* `getLexemes`: used for search suggestions, returns up to 10 lexemes that begin with a given string.
* `getSense`: given a sense ID, returns all information about the sense, including the synset it belongs to and all related senses (that get grouped by relations sorted by relation priority).
* `getHyponyms`: returns an array of paths (also arrays) of hyponyms for a given sense ID.

#### Controllers

Controller is a defined set of functionality that handles data on a certain scope. Angular.js doesn’t differentiate a model as a separate unit. Controllers get data from a factory and can perform operations on it, including listening to user actions in a view.

![](http://imgur.com/Y4RZAsZ.png)

There are 3 controllers in the application:

* `SearchCtrl`: handles the search field, search suggestions, and selecting the current sense.
* `SenseCtrl`: created by the router (inside the `ng-view` element which can be found in the layout) when the *main* sense is loaded.
* The third one is `HyponymsCtrl`, the modal window created by `SenseCtrl` on the fly.

#### Directives

Angular templates introduce plenty of custom HTML attributes (*tied* to specific elements) called directives. Custom directives can also be added.

Wordnet makes use of 2 custom directives:

* `item-flag`: if the attribute is set for the `.item__lemma` element, it’s given an appropriate CSS class name that adds a corresponding flag to the synset.
* `sense-tooltip`: given a synset object, this directive composes the contents of the `title` attribute and sets it for the element.

#### Filters

Filters are independent utilities that can be accessed inside directives (they return specific values).

The application introduces 2 filters:

* `inflect`: given a word and a number, it returns the inflected version of the word (`połączenie`, `2` → `połączenia`). It’s not a universal solution that handles Polish language—all words and their versions have to be specified manually.
* `toRelationName`: given a relation object and direction of the relation (`incoming` or `outgoing`), the filter chooses between `relation.name`/ `relation.reverse_name` and provides fallback if the name isn’t defined.

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
