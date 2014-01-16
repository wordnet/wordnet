App = angular.module('wordnet')

App.filter 'getRelationName', ->
  toString = (value) ->
    '' + (value || '')

  tweak = (name) ->
    n = toString(name).replace(/_+/g, ' ')
    n.substr(0, 1).toUpperCase() + n.substr(1)

  (relation, direction) ->
    name = tweak(relation.name)
    reverse_name = tweak(relation.reverse_name)
    direction = toString(direction).toLowerCase()

    return name unless direction == 'outgoing'
    return reverse_name if reverse_name
    "← (#{name || 'Relacja nieoznaczona'})"

App.controller 'SearchCtrl', ($scope, getLexemes, getSense, getRelations, $modal) ->
  $scope.getLexemes = getLexemes
  $scope.getSense = getSense

  $scope.senses = []
  $scope.current_sense = 0

  $scope.loadRelations = ->
    getRelations().then (relations) ->
      $scope.relations = _.indexBy(relations, (r) -> r.id)

  $scope.onLexemeSelect = (lexeme) ->
    $scope.lexeme = lexeme.lemma
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
      $scope.current_sense = 0

  $scope.onSenseSelect = (sense_id) ->
    $scope.senses = []
    $scope.loadSense(sense_id)

  $scope.showHyponyms = (sense_id) ->
    $modal.open
      templateUrl: 'hyponymsTemplate.html'
      controller: 'HyponymCtrl'
      resolve:
        sense_id: -> sense_id
