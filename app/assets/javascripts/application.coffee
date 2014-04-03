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
    verb_pl: "Verb"
    noun_pl: "Noun"
    adverb_pl: "Adverb"
    adjective_pl: "Adjective"
    verb_pwn: "Verb PWN"
    noun_pwn: "Noun PWN"
    adverb_pwn: "Adverb PWN"
    adjective_pwn: "Adjective PWN"
    i_from_n_lexical_units: "{{i}} of {{n}} lexical&nbsp;units"
    use_search_bar_to_begin: "Use search bar to begin"
    next: "Next"
    previous: "Previous"
    show_n_other_connections: "Show {{n}} more connections"
    i_from_n_paths: "{{i}} of {{n}} paths"
    back: "Go back"
    statistics: "Statistics"
    polysemy: 'All Lemma'
    polysemy_nomono: 'Only Polisemous Lemma'
    average_polysemy: 'Average Polisemy'
    lemmas: 'Lemmas'
    lexemes: 'Lexical Units'
    synsets: 'Synsets'
    monosemous_lemmas: 'Monosemous Lemmas'
    polysemous_lemmas: 'Polysemous Lemmas'
    aspects_of_enwordnet: 'Princeton Wordnet Aspects'
    aspects_of_plwordnet: 'Polish Wordnet Aspects'
    synset_size_ratio: 'Sizes of Synsets'
    lemma_synsets_ratio: 'Number of Synsets Lemma belongs to (%)'
    pl_synset_relations: 'Słowosieć Synset Relations'
    pl_sense_relations: 'Słowosieć Sense Relations'
    en_synset_relations: 'Princeton Synset Relations'
    en_sense_relations: 'Princeton Sense Relations'
    sum: 'Sum'

  $translateProvider.translations 'pl',
    synonyms: "Synonimy"
    source: "Źródło"
    examples: "Przykłady"
    hyperonyms: "Hiperonimy"
    show_hyperonym_path: "Pokaż ścieżkę hiperonimów"
    verb_pl: "Czasownik"
    noun_pl: "Rzeczownik"
    adverb_pl: "Przysłówek"
    adjective_pl: "Przymiotnik"
    verb_pwn: "Czasownik PWN"
    noun_pwn: "Rzeczownik PWN"
    adverb_pwn: "Przysłówek PWN"
    adjective_pwn: "Przymiotnik PWN"
    i_from_n_lexical_units: "{{i}} z {{n}} jednostek&nbsp;leksykalnych"
    use_search_bar_to_begin: "Użyj wyszukiwarki by rozpocząć"
    previous: "Poprzednia"
    next: "Następna"
    show_n_other_connections: "Pokaż pozostałe {{n}}&nbsp;{{ 'połączenie' | inflect:n }}"
    i_from_n_paths: "{{i}} z {{n}} ścieżek"
    back: "Powrót"
    statistics: "Statystyki"
    polysemy: 'Wszystke lemma'
    polysemy_nomono: 'Polisemiczne lemma'
    average_polysemy: 'Średnia polisemia'
    lemmas: 'Lemma'
    lexemes: 'Jednostki Leksykalne'
    synsets: 'Synsety'
    monosemous_lemmas: 'Monosemiczne Lemma'
    polysemous_lemmas: 'Polisemiczne Lemma'
    aspects_of_enwordnet: 'Pewne aspekty Princeton Wordnet'
    aspects_of_plwordnet: 'Pewne aspekty Słowosieci'
    synset_size_ratio: 'Wielkość synsetów'
    lemma_synsets_ratio: 'Ilość synsetów do których należy lemma (%)'
    pl_synset_relations: 'Relacje synsetów w Słowosieci'
    pl_sense_relations: 'Relacje jedostek leksykalnych w Słowosieci'
    en_synset_relations: 'Relacje synsetów w Princeton Wordnet'
    en_sense_relations: 'Relacje jednostek leksykalnych w Princeton Wordnet'
    sum: 'Suma'

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

    $routeProvider.when '/stats',
      templateUrl: 'stats.html'

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
