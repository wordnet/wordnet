#= require lodash
#= require data
#= require angular
#= require angular-bootstrap
#= require_self
#= require_tree ./controllers
#= require_tree ./directives

App = angular.module('wordnet', ['ui.bootstrap'])

App.factory 'lexemes', ($http, $q) ->
  (prefix) ->
    $http.get("/api/lexemes/#{prefix}", cache: true).then (response) ->
      response.data
