angular.module('wordnet').controller 'StatsCtrl', [
  '$scope', '$http',
  ($scope, $http) ->
    $http.get('/api/stats', cache: true).then (response) ->
      $scope.stats = response.data
]
