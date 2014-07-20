angular.module('wordnet').filter 'reverse', ->
  (word) ->
    word.split("").reverse().join("")

angular.module('wordnet').filter 'translate_pos', ($filter) ->
  (word) ->
    $filter('translate')(word.split('_')[0])
