#= require lodash
#= require angular
#= require angular-bootstrap
#= require angular-route
#= require_self
#= require_tree ./controllers
#= require_tree ./filters

DOMAIN = "http://localhost:3000"

App = angular.module('wordnet', ['ui.bootstrap', 'ngRoute'])

App.factory 'getLexemes', ($http) ->
  (prefix) ->
    $http.get("#{DOMAIN}/api/lexemes/#{prefix}", cache: true).then (response) ->
      response.data

App.factory 'getHyponyms', ($http) ->
  (sense_id) ->
    $http.get("#{DOMAIN}/api/hyponyms/#{sense_id}", cache: true).then (response) ->
      response.data

App.factory 'getSense', ($http, getRelations) ->
  (sense_id) ->
    getRelations().then (relations) ->
      $http.get("#{DOMAIN}/api/senses/#{sense_id}", cache: true).then (response) ->
        sense = response.data
        angular.forEach sense.relations, (relation) ->
          relation.type = relations[relation.relation_id]
          relation.priority = relations[relation.relation_id].priority
        angular.forEach sense.reverse_relations, (relation) ->
          relation.type = relations[relation.relation_id]
          relation.priority = relations[relation.relation_id].priority

        sense

App.factory 'getRelations', ($http) ->
  ->
    $http.get("#{DOMAIN}/api/relations", cache: true).then (response) ->
      _.indexBy(response.data, (r) -> r.id)

