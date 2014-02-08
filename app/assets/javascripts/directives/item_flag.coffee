angular.module('wordnet').directive 'itemFlag', ->
  lemmaClassName = 'item__lemma'

  toFlaggedClassName = (code) ->
    lemmaClassName + '--' + code

  toClassNames = _.memoize (country) ->
    _(country.toLowerCase().split(/[^a-z]+/i)).unique()
      .map(toFlaggedClassName).join(' ')

  {
    restrict: 'A'
    replace: false
    scope:
      itemFlag: '='
    link: (scope, element, attributes) ->
      return unless element.hasClass(lemmaClassName)

      scope.$watch 'itemFlag', (new_country, old_country) ->
        if _.isString(old_country)
          element.removeClass(toClassNames(old_country))

        if _.isString(new_country)
          element.addClass(toClassNames(new_country))
  }
