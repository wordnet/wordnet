angular.module('wordnet').controller 'SenseCtrl', [
  '$scope', 'getSense', 'getRelations', '$modal', '$routeParams', 'relations', 'sense',
  ($scope, getSense, getRelations, $modal, $routeParams, relations, sense) ->
    $scope.sense = null
    $scope.sense_index = 0
    $scope.relations = _.indexBy(relations, (r) -> r.id)

    if sense
      $scope.sense = sense
      $scope.sense_index = sense.homographs.indexOf(sense.id)

    $scope.showHyponyms = (sense_id) ->
      $modal.open
        templateUrl: 'hyponymsTemplate.html'
        controller: 'HyponymCtrl'
        resolve:
          sense_id: -> sense_id
]
