App = angular.module('wordnet')

App.filter "byRelationId",  ->
  (collection) ->
    _.memoize (collection) ->
      _.groupBy collection, (item) ->
        item.relation_id

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

  $scope.truncateAfter = (senses) ->
    3
