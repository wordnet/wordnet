App = angular.module('wordnet')
  
App.controller 'SenseCtrl', ($scope, $modal, relations, sense, $state) ->
  $scope.sense = null
  $scope.sense_index = 0
  $scope.relations = _.indexBy(relations, (r) -> r.id)

  $scope.current = { selected: undefined }
  $scope.$watch 'current.selected', (value) ->
    return unless value
    $state.go('sense', senseId: value.id)
    $scope.current.selected = undefined

  if sense
    $scope.sense = sense
    $scope.sense_index = _.findIndex(sense.homographs, id: sense.id)

  $scope.showHyponyms = (sense_id) ->
    $modal.open
      templateUrl: 'hyponymsTemplate.html'
      controller: 'HyponymCtrl'
      resolve:
        sense_id: -> sense_id
