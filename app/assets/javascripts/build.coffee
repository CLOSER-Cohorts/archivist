build = angular.module('archivist.build', [
  'templates',
  'ngRoute',
  'archivist.flash',
  'archivist.data_manager',
  'archivist.realtime'
])

build.config(['$routeProvider',
  ($routeProvider)->
    $routeProvider
    .when('/instruments/:id/build',
      templateUrl: 'partials/build/index.html'
      controller: 'BuildMenuController'
    )
    .when('/instruments/:id/build/code_lists/:code_list_id?',
      templateUrl: 'partials/build/editor.html'
      controller: 'BuildCodeListsController'
    )
    .when('/instruments/:id/build/response_domains/:response_domain_type?/:response_domain_id?',
      templateUrl: 'partials/build/editor.html'
      controller: 'BuildResponseDomainsController'
    )
    .when('/instruments/:id/build/questions/:question_type?/:question_id?',
      templateUrl: 'partials/build/editor.html'
      controller: 'BuildQuestionsController'
    )
    .when('/instruments/:id/build/constructs',
      templateUrl: 'partials/build/editor.html'
      controller: 'BuildConstructsController'
      reloadOnSearch: false
    )
])