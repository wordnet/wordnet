#= require lodash
#= require angular
#= require angular-bootstrap
#= require angular-cookies
#= require angular-ui-router
#= require angular-sanitize
#= require angular-translate
#= require angular-translate-storage-local
#= require angular-translate-storage-cookie
#= require ui-select
#= require_self
#= require_tree ./factories
#= require_tree ./controllers
#= require_tree ./directives
#= require_tree ./filters

App = angular.module 'wordnet', [
  'ui.router'
  'ngCookies'
  'ngSanitize'
  'ui.bootstrap.typeahead'
  'ui.bootstrap'
  'pascalprecht.translate'
  'pascalprecht.translate'
  'ui.select'
]

App.config ($translateProvider) ->
  $translateProvider.useLocalStorage()
  $translateProvider.preferredLanguage('pl')

App.config (uiSelectConfig) ->
  uiSelectConfig.theme = 'selectize'

App.run ($templateCache) ->
  $templateCache.put('selectize/choices.tpl.html', '<div ng-show="$select.open" class="ui-select-choices selectize-dropdown single"> <div class="ui-select-choices-content selectize-dropdown-content" onmousewheel="preventScrolling(this)"> <div class="ui-select-choices-row" ng-class="{\'active\': $select.activeIndex===$index}"> <div class="option" data-selectable ng-transclude></div> </div> </div> </div> ')

App.run ($rootScope, $translate, $interpolate) ->

  window.preventScrolling = (t) ->
    e = event
    return unless e && t
    if (e.deltaY > 0 and t.clientHeight + t.scrollTop == t.scrollHeight) or (e.deltaY < 0 and t.scrollTop == 0)
      e.stopPropagation()
      e.preventDefault()
      return false

    true

  $rootScope.lexicalUnitsValues =
    $interpolate('{ i: "{{sense_index + 1}}", n: "{{sense.homographs.length}}" }')

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

    $stateProvider.state 'unknown',
      url: '/unknown/{lemma:[^/]*}'
      templateUrl: '/templates/unknown'
      controller: 'UnknownCtrl'
      resolve:
        lemma: [
          '$stateParams',  ($stateParams) ->
            $stateParams.lemma
        ]

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
