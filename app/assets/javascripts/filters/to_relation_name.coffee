App = angular.module('wordnet')

App.filter 'toRelationName', ->
  toString = (value) ->
    '' + (value || '')

  tweak = (name) ->
    n = toString(name).replace(/_+/g, ' ')
    n.substr(0, 1).toUpperCase() + n.substr(1)

  (relation, direction) ->
    name = tweak(relation.name)
    reverse_name = tweak(relation.reverse_name)
    direction = toString(direction).toLowerCase()

    return name unless direction == 'incoming'
    return reverse_name if reverse_name
    "← (#{name || 'Relacja nieoznaczona'})"
