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
    change_language: 'Change language:'
    leader: "Leader"
    coordinator: "Coordinators"
    developer: "Developers"
    lexograph: "Linguists"
    about_wordnet: "About plWordnet"
    team: "Team"
    publications: "Publications"
    contact: "Contact"
    archive_versions: "Archive Versions"
    learn_more: 'Learn more'

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
    polysemy: 'Wszystkie lematy'
    polysemy_nomono: 'Polisemiczne lematy'
    average_polysemy: 'Średnia polisemia'
    lemmas: 'Lematy'
    lexemes: 'Jednostki leksykalne'
    synsets: 'Synsety'
    monosemous_lemmas: 'Monosemiczne lemma'
    polysemous_lemmas: 'Polisemiczne lemma'
    aspects_of_enwordnet: 'Wybrane statystyki Princeton Wordnet (PWN)'
    aspects_of_plwordnet: 'Wybrane statystyki Słowosieci'
    synset_size_ratio: 'Wielkość synsetów'
    lemma_synsets_ratio: 'Liczba synsetów do których należy lemma (%)'
    pl_synset_relations: 'Relacje synsetów w Słowosieci'
    pl_sense_relations: 'Relacje jednostek leksykalnych w Słowosieci'
    en_synset_relations: 'Relacje synsetów w Princeton Wordnet'
    en_sense_relations: 'Relacje jednostek leksykalnych w Princeton Wordnet'
    sum: 'Suma'
    change_language: 'Zmień język:'
    leader: "Kierownik"
    coordinator: "Koordynatorzy"
    developer: "Programiści"
    lexograph: "Lingwiści"
    about_wordnet: "O Słowosieci"
    team: "Zespół"
    publications: "Publikacje"
    contact: "Kontakt"
    archive_versions: "Wersje Archiwalne"
    learn_more: 'Dowiedz się więcej'

  $translateProvider.useLocalStorage()
  $translateProvider.preferredLanguage('pl')

App.run ($rootScope, $translate) ->

  $rootScope.config =
    language: $translate.use()

  $rootScope.toggleLanguage = (language) ->
    $translate.use(language)
    $rootScope.config.language = language

  $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
    console.error { error, event, toState, toParams, fromState, fromParams }

App.config ($stateProvider, $locationProvider) ->
    ['stats', 'team', 'about'].forEach (page) ->
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
