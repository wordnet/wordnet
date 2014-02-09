angular.module('wordnet').factory 'getHyponyms', [
  '$http', ($http) ->
    (sense_id) ->
      $http.get("/api/hyponyms/#{sense_id}", cache: true).then (response) ->
        response.data
]
