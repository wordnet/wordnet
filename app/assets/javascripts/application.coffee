#= require lodash
#= require angular
#= require angular-bootstrap
#= require_self
#= require_tree ./controllers
#= require_tree ./directives
#= require_tree ./filters

DOMAIN = "http://localhost:3000"

App = angular.module('wordnet', ['ui.bootstrap'])

App.factory 'getLexemes', ($http) ->
  (prefix) ->
    $http.get("#{DOMAIN}/api/lexemes/#{prefix}", cache: true).then (response) ->
      response.data

App.factory 'getSense', ($http) ->
  (sense_id) ->
    $http.get("#{DOMAIN}/api/senses/#{sense_id}", cache: true).then (response) ->
      response.data

App.factory 'getRelations', ($http) ->
  ->
    $http.get("#{DOMAIN}/api/relations", cache: true).then (response) ->
      response.data
