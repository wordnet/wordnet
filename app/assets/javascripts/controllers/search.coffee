App = angular.module('wordnet')

App.filter 'tweakRelationName', ->
  (name) ->
    return 'Nieoznaczona relacja' unless name

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
    $scope.senses = []
    $scope.pendingLoad = lexeme.senses
    $scope.pushSense($scope.pendingLoad.shift())

  $scope.pushSense = (sense_id) ->
    getSense(sense_id).then (sense) ->
      $scope.senses.push(sense)
      if nextPending = $scope.pendingLoad.shift()
        $scope.pushSense(nextPending)

  $scope.loadSense = (sense_id) ->
    getSense(sense_id).then (sense) ->
      $scope.senses = [sense]

  $scope.onSenseSelect = (sense_id) ->
    $scope.senses = []
    $scope.loadSense(sense_id)

