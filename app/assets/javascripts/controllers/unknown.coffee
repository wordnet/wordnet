App = angular.module('wordnet')

App.controller 'UnknownCtrl', ($scope, lemma) ->
  $scope.lemma = lemma
