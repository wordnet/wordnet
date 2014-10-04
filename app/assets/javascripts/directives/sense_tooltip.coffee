angular.module('wordnet').directive 'senseTooltip', ->
  restrict: 'A'
  scope:
    senseTooltip: '='
  link: (scope, element, attributes) ->
    scope.$watch 'senseTooltip', (sense) ->
      title = ''

      if sense?
        title += sense.lemma
        title += " (#{sense.part_of_speech})" if sense.part_of_speech
        title += " — #{sense.definition}" if sense.definition

      element.attr('title', title)
