App = angular.module('wordnet')

App.directive 'inflect', ->
  restrict: 'E'
  replace: true
  link: (scope, element, attributes) ->
    count = +attributes.count
    word = switch attributes.word
      when 'połączenie' then switch
        when count == 1 then 'połączenie'
        when _.contains([1, 2, 3, 4], count % 10) then 'połączenia'
        else 'połączeń'
      when 'pozostały' then switch
        when count == 1 then 'pozostały'
        else 'pozostałe'
      else null

    unless _.isNull(word)
      options = {word, count}
      template = attributes.template || '${count} ${word}'
      element.html _.template(template, options)
