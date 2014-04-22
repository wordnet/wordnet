#= require lodash
#= require angular
#= require angular-bootstrap
#= require angular-cookies
#= require angular-ui-router
#= require angular-translate
#= require angular-translate-storage-local
#= require angular-translate-storage-cookie
#= require_self
#= require_tree ./factories
#= require_tree ./controllers
#= require_tree ./directives
#= require_tree ./filters

App = angular.module 'wordnet', [
  'ui.router'
  'ngCookies'
  'ui.bootstrap'
  'pascalprecht.translate'
]

App.config ($translateProvider) ->
  $translateProvider.useLocalStorage()
  $translateProvider.preferredLanguage('pl')

App.run ($rootScope, $translate) ->

  $rootScope.config =
    language: $translate.use()

  $rootScope.toggleLanguage = (language) ->
    $translate.use(language)
    $rootScope.config.language = language

  $rootScope.$on '$stateChangeError',
  (event, toState, toParams, fromState, fromParams, error) ->
    console.error { error, event, toState, toParams, fromState, fromParams }

App.config ($stateProvider, $locationProvider) ->
    ['stats', 'team', 'about', 'contact'].forEach (page) ->
      $stateProvider.state page,
        url: '/' + page
        templateUrl: '/templates/' + page

    $stateProvider.state 'index',
      url: '/'
      controller: 'SenseCtrl'
      templateUrl: '/templates/index'
      resolve:
        relations: -> []
        sense: -> undefined

    $stateProvider.state 'sense',
      url: '/{senseId:[^/]*}'
      controller: 'SenseCtrl'
      templateUrl: '/templates/index'
      resolve:
        relations: [
          'getRelations', (getRelations) ->
            getRelations()
        ]
        sense: [
          '$stateParams', 'getSense', ($stateParams, getSense) ->
            getSense($stateParams.senseId)
        ]

    $locationProvider.html5Mode(true)
