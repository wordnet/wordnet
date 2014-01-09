App = angular.module('wordnet')

App.filter 'tweakRelationName', ->
  (name) ->
    n = ('' + name).replace(/_+/g, ' ')
    n.substr(0, 1).toUpperCase() + n.substr(1)

App.controller 'SearchCtrl', ($scope, getLexemes, getSense, getRelations) ->
  $scope.getLexemes = getLexemes
  $scope.getSense = getSense

  $scope.senses = []

  $scope.loadRelations = ->
    getRelations().then (relations) ->
      $scope.relations = _.indexBy(relations, (r) -> r.id)

  $scope.onLexemeSelect = (lexeme) ->
    # You want to fetch all of them, just sample
    $scope.loadSense(lexeme.senses[0])

  $scope.loadSense = (sense_id) ->
    getSense(sense_id).then (sense) ->
      $scope.senses = [sense]
