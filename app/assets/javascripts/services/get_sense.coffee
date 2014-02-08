angular.module('wordnet').factory 'getSense', [
  '$http', 'getRelations', ($http, getRelations) ->
    (sense_id) ->
      getRelations().then (relations) ->
        $http.get("/api/senses/#{sense_id}", cache: true).then (response) ->
          sense = response.data

          angular.forEach sense.outgoing, (relation) ->
            relation.type = relations[relation.relation_id]
            relation.priority = relations[relation.relation_id].priority

          angular.forEach sense.incoming, (relation) ->
            relation.type = relations[relation.relation_id]
            relation.priority = relations[relation.relation_id].priority
            relation.no_reverse = !!relations[relation.relation_id].reverse_name

          sense
]
