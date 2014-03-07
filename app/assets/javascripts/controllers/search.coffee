angular.module('wordnet').controller 'SearchCtrl', [
  '$scope', '$location', '$anchorScroll', 'getLexemes', "$translate"
  ($scope, $location, $anchorScroll, getLexemes, $translate) ->
    $scope.getLexemes = getLexemes

    $scope.onLexemeSelect = (lexeme) ->
      $location.path("/#{lexeme.sense_id}")
      $anchorScroll()

    $scope.changeLanguage = (name) ->
      $translate.use(name)
]
