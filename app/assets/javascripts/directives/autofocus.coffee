App = angular.module('wordnet')

App.directive 'autofocus', ($timeout) ->
  (scope, element, attrs) ->
    element.on 'focus', ->
      $timeout ->
        element[0].select()
