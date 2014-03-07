#= require lodash
#= require angular
#= require angular-bootstrap
#= require angular-cookies
#= require angular-route
#= require angular-translate
#= require angular-translate-storage-local
#= require angular-translate-storage-cookie
#= require_self
#= require_tree ./factories
#= require_tree ./controllers
#= require_tree ./directives
#= require_tree ./filters

angular.module('wordnet', [
  'ngRoute'
  'ngCookies'
  'ui.bootstrap'
  'pascalprecht.translate'
])

angular.module('wordnet').config ['$translateProvider', ($translateProvider) ->

  $translateProvider.translations 'en',
    synonyms: "Synonyms"
    source: "Source"
    examples: "Examples"
    hyperonyms: "Hyperonyms"
    show_hyperonym_path: "Show hyperonym path"
    verb: "Verb"
    noun: "Noun"
    adverb: "Adverb"
    adjective: "Adjective"
    i_from_n_lexical_units: "{{i}} of {{n}} lexical&nbsp;units"
    use_search_bar_to_begin: "Use search bar to begin"
    next: "Next"
    previous: "Previous"
    show_n_other_connections: "Show {{n}} more connections"
    i_from_n_paths: "{{i}} of {{n}} paths"
    back: "Go back"

  $translateProvider.translations 'pl',
    synonyms: "Synonimy"
    source: "Źródło"
    examples: "Przykłady"
    hyperonyms: "Hiperonimy"
    show_hyperonym_path: "Pokaż ścieżkę hiperonimów"
    verb: "Czasownik"
    noun: "Rzeczownik"
    adverb: "Przysłówek"
    adjective: "Przymiotnik"
    i_from_n_lexical_units: "{{i}} z {{n}} jednostek&nbsp;leksykalnych"
    use_search_bar_to_begin: "Użyj wyszukiwarki by rozpocząć"
    previous: "Poprzednia"
    next: "Następna"
    show_n_other_connections: "Pokaż pozostałe {{n}}&nbsp;{{ 'połączenie' | inflect:n }}"
    i_from_n_paths: "{{i}} z {{n}} ścieżek"
    back: "Powrót"

  $translateProvider.useLocalStorage()
  $translateProvider.preferredLanguage('pl')
]

angular.module('wordnet').config [
  '$routeProvider', '$locationProvider',
  ($routeProvider, $locationProvider) ->
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
