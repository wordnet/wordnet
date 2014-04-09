angular.module('wordnet').controller 'SearchCtrl', [
  '$scope', '$location', '$anchorScroll', 'getLexemes', "$translate"
  ($scope, $location, $anchorScroll, getLexemes, $translate) ->
    $scope.enter = false

    $scope.getLexemes = (name) ->
      getLexemes(name).then (lexemes) ->
        if $scope.enter
          $scope.onLexemeSelect(lexemes[0]) if lexemes.length > 0
          []
        else
          lexemes

    $scope.onLexemeSelect = (lexeme) ->
      $scope.matches = []
      $scope.enter = false
      $scope.lexeme = lexeme.lemma
      $location.path("/#{lexeme.sense_id}")
      $anchorScroll()

    $scope.onEnter = ->
      $scope.enter = true

    $scope.changeLanguage = (name) ->
      $translate.use(name)
]
