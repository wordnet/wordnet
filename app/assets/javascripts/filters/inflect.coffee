App = angular.module('wordnet')

App.filter 'inflect', ->
  (word, count) ->
    count = parseInt(count)
    switch word
      when 'połączenie' then switch
        when count == 1 then 'połączenie'
        when _.contains([2, 3, 4], count % 10) && !_.contains([11..19], count % 100) then 'połączenia'
        else 'połączeń'
      else word
