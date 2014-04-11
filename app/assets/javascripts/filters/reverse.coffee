angular.module('wordnet').filter 'reverse', ->
  (word) ->
    word.split("").reverse().join("")
