App = angular.module('wordnet')

App.directive 'preventDefault', ->
  (scope, element, attributes) ->
    element.bind 'click', (event) ->
      event.preventDefault()
