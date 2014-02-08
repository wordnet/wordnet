angular.module('wordnet').controller 'SearchCtrl', [
  '$scope', '$location', '$anchorScroll', 'getLexemes',
  ($scope, $location, $anchorScroll, getLexemes) ->
    $scope.getLexemes = getLexemes

    $scope.onLexemeSelect = (lexeme) ->
      $location.path("/#{lexeme.senses[0]}")
      $anchorScroll()
]
