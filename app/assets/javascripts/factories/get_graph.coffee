App = angular.module('wordnet')

App.factory 'getGraph', ($http, getRelations) ->
  (nodeIds) ->
    getRelations().then (relations) ->
      $http.get("/api/graph/#{nodeIds[0]}", params: { "nodes[]": nodeIds }, cache: true).then (response) ->
        data = response.data

        if angular.isArray(data.relations)
          angular.forEach data.relations, (relation) ->
            relation.type = relations[relation.id]
            relation.priority = relations[relation.id].priority

        data
