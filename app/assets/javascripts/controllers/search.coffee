App = angular.module('wordnet')

App.config ($routeProvider, $locationProvider) ->
  $routeProvider.when '/',
    controller: 'SenseCtrl'
    templateUrl: 'index.html'

  $routeProvider.when '/:senseId',
    controller: 'SenseCtrl'
    templateUrl: 'index.html'
    resolve:
      relations: (getRelations) ->
        getRelations()
      sense: ($route, getSense) ->
        getSense($route.current.params.senseId)

  $locationProvider.html5Mode(true)

App.controller 'SenseCtrl', ($scope, getSense, getRelations, $modal, $routeParams, relations, sense) ->
  $scope.sense = null
  $scope.sense_index = 0

  $scope.relations = _.indexBy(relations, (r) -> r.id)
  $scope.sense = sense
  $scope.sense_index = sense.homographs.indexOf(sense.id)

  $scope.showHyponyms = (sense_id) ->
    $modal.open
      templateUrl: 'hyponymsTemplate.html'
      controller: 'HyponymCtrl'
      resolve:
        sense_id: -> sense_id

App.controller 'SearchCtrl', ($scope, $location, $anchorScroll, getLexemes) ->
  $scope.getLexemes = getLexemes

  $scope.onLexemeSelect = (lexeme) ->
    $location.path("/#{lexeme.senses[0]}")
    $anchorScroll()
