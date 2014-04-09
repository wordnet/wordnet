App = angular.module('wordnet')

App.directive 'ngEnter', ->
  (scope, element, attrs) ->
    element.bind "keypress", (event) ->
      if event.which == 13
        scope.$apply ->
          scope.$eval(attrs.ngEnter)
