@app.directive 'preventDefault', ->
  (scope, element, attributes) ->
    if attributes.ngClick
      element.bind 'click', (event) ->
        event.preventDefault()
