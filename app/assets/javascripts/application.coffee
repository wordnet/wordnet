#= require lodash
#= require angular
#= require angular-bootstrap
#= require angular-route
#= require_self
#= require_tree ./services
#= require_tree ./controllers
#= require_tree ./directives
#= require_tree ./filters

angular.module('wordnet', ['ngRoute', 'ui.bootstrap']).config [
  '$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $routeProvider.when '/',
      controller: 'SenseCtrl'
      templateUrl: 'index.html'
      resolve:
        relations: -> []
        sense: -> undefined

    $routeProvider.when '/:senseId',
      controller: 'SenseCtrl'
      templateUrl: 'index.html'
      resolve:
        relations: [
          'getRelations', (getRelations) ->
            getRelations()
        ]
        sense: [
          '$route', 'getSense', ($route, getSense) ->
            getSense($route.current.params.senseId)
        ]

    $locationProvider.html5Mode(true)
]
