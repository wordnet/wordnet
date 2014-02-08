angular.module('wordnet').controller 'HyponymCtrl', [
  '$scope', '$modalInstance', 'getHyponyms', 'sense_id',
  ($scope, $modalInstance, getHyponyms, sense_id) ->
    $scope.hyponyms = []
    $scope.index = 0

    getHyponyms(sense_id).then (hyponyms) ->
      $scope.hyponyms = hyponyms

    $scope.next = ->
      $scope.index += 1

    $scope.previous = ->
      $scope.index -= 1

    $scope.closeModal = ->
      $modalInstance.dismiss()
]
