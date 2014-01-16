App = angular.module('wordnet')

App.controller 'HyponymCtrl', ($scope, $modalInstance, getHyponyms, sense_id) ->
  $scope.hyponyms = []

  getHyponyms(sense_id).then (hyponyms) ->
    $scope.hyponyms = _(hyponyms).flatten().reverse().value()

  $scope.closeModal = ->
    $modalInstance.dismiss()
