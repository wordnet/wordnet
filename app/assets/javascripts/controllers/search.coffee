@app.controller 'SearchCtrl', ($scope) ->
  relations = {}

  _(synset_relations).groupBy('direction').forIn (collection, direction) ->
    relations[direction] = []

    _(collection).groupBy('name').forIn (collection, name) ->
      relations[direction].push
        name: name
        children: _(collection).sortBy('lemma').pluck('related_to').value()
        truncate_after: 3

  # Mimicking the case of multiple results on a single page
  synset_data = _.extend(main_synset, senses: relations)
  synsets = _.map([synset_data, synset_data], _.cloneDeep)

  $scope.synsets = synsets

  $scope.goTo = (id) ->
    console.log id
