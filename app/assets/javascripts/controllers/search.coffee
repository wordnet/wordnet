App = angular.module('wordnet')
  
App.controller 'SearchCtrl', ($scope, $state, $anchorScroll, getLexemes, $translate) ->
    $scope.enter = false

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
      $scope.lexeme = lexeme.lemma

      $state.go('sense', senseId: lexeme.sense_id)

      $anchorScroll()

    $scope.onEnter = ->
      $scope.enter = true

    $scope.changeLanguage = (name) ->
      $translate.use(name)
