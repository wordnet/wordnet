App = angular.module('wordnet')

App.controller 'HyponymCtrl', ($scope, $modalInstance, getHyponyms, sense_id) ->
  $scope.hyponyms = []
  $scope.index = 0

  $scope.next = ->
    $scope.index += 1

  $scope.previous = ->
    $scope.index -= 1

  getHyponyms(sense_id).then (hyponyms) ->
    console.log(hyponyms)
    $scope.hyponyms = hyponyms

  $scope.closeModal = ->
    $modalInstance.dismiss()
