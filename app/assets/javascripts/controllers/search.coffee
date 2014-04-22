App = angular.module('wordnet')

App.controller 'SearchCtrl', ($scope, $state, $anchorScroll, getLexemes, $translate) ->
  $scope.enter = false
  $scope.changed = false
  $scope.lastLexeme = null

  $scope.getLexemes = (name) ->
    getLexemes(name).then (lexemes) ->
      if $scope.enter
        $scope.onLexemeSelect(lexemes[0]) if lexemes.length > 0
        $scope.enter = false
        []
      else
        $scope.enter = false
        lexemes

  $scope.onLexemeSelect = (lexeme) ->
    $scope.enter = false
    $scope.changed = false
    $scope.lexeme = lexeme.lemma
    $scope.lastLexeme = lexeme

    $state.go('sense', senseId: lexeme.sense_id)

    $anchorScroll()

  $scope.onEnter = ->
    $scope.enter = true
    if !$scope.changed && $scope.lastLexeme
      $state.go('sense', senseId: $scope.lastLexeme.sense_id)
      $anchorScroll()
      $scope.enter = false

  $scope.onChange = ->
    $scope.changed = true
    $scope.lastLexeme = null

  $scope.changeLanguage = (name) ->
    $translate.use(name)
