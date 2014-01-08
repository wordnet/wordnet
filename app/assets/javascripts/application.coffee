#= require lodash
#= require data
#= require angular
#= require angular-bootstrap
#= require_self
#= require_tree ./controllers
#= require_tree ./directives

DOMAIN = "http://8cca7fb.ngrok.com"

App = angular.module('wordnet', ['ui.bootstrap'])

App.factory 'getLexemes', ($http, $q) ->
  (prefix) ->
    $http.get("#{DOMAIN}/api/lexemes/#{prefix}", cache: true).then (response) ->
      response.data

App.factory 'getSense', ($http, $q) ->
  (sense_id) ->
    $http.get("#{DOMAIN}/api/senses/#{sense_id}", cache: true).then (response) ->
      response.data
