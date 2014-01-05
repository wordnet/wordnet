@app.directive 'preventDefault', ->
  (scope, element, attributes) ->
    element.bind 'click', (event) ->
      event.preventDefault()
