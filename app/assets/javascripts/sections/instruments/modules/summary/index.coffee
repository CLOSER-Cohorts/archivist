#= require_self
#= require_tree .

build = angular.module('archivist.summary', [
  'templates',
  'ngRoute'
])

build.config(['$routeProvider',
  ($routeProvider)->
    $routeProvider
    .when('/instruments/:id/summary',
      templateUrl: 'partials/summary/index.html'
      controller: 'SummaryIndexController'
    )
    .when('/instruments/:id/summary/:object_type',
      templateUrl: 'partials/summary/show.html'
      controller: 'SummaryShowController'
    )
])