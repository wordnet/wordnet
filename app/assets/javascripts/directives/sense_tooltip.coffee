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
        title += " — #{sense.comment}" if sense.comment

      element.attr('title', title)
