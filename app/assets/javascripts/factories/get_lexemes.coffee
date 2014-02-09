angular.module('wordnet').factory 'getLexemes', [
  '$http', ($http) ->
    (phrase) ->
      $http.get("/api/lexemes/#{phrase}", cache: true).then (response) ->
        response.data
]
