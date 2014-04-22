angular.module('wordnet').filter 'toRelationName', ($filter) ->
  toString = (value) ->
    '' + (value || '')

  tweak = (name) ->
    n = toString(name).replace(/_+/g, ' ')
    n.substr(0, 1).toUpperCase() + n.substr(1)

  (relation, direction) ->
    name = tweak($filter('translate')(relation.name))
    reverse_name = relation.reverse_name && tweak($filter('translate')(relation.reverse_name))
    direction = toString(direction).toLowerCase()

    return name unless direction == 'incoming'
    return reverse_name if reverse_name
    "← #{name || 'Relacja nieoznaczona'}"
