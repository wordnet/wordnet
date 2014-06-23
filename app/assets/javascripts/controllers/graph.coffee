App = angular.module('wordnet')
  
App.controller 'GraphCtrl', ($scope, $modal, relations, graphData, $state) ->
  $scope.relations = _.indexBy(relations, (r) -> r.id)
  $scope.graphData = graphData

  # $scope.graphData =
  #   nodes: [{
  #     id: 'BBB'
  #     lemma: 'Node A'
  #     sense_index: 1
  #   },{
  #     id: 'AAA'
  #     lemma: 'Node B'
  #     sense_index: 1
  #   }]

  #   links: [{
  #     id: 10
  #     source_id: 'AAA'
  #     target_id: 'BBB'
  #   }]
