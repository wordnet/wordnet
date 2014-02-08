angular.module('wordnet').factory 'getRelations', [
  '$http', ($http) ->
    ->
      $http.get("/api/relations", cache: true).then (response) ->
        _.indexBy(response.data, (r) -> r.id)
]
