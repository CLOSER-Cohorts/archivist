#= require_self
#= require ./modules

datasets = angular.module('archivist.datasets', [
  'templates',
  'ngRoute',
  'archivist.datasets.index',
  'archivist.datasets.show'
])

datasets.config(
  [
    '$routeProvider',
    ($routeProvider)->
      $routeProvider
      .when('/datasets',
        templateUrl: 'partials/datasets/index.html'
        controller: 'DatasetsIndexController'
      )
      .when('/datasets/:id',
        templateUrl: 'partials/datasets/show.html'
        controller: 'DatasetsShowController'
      )
      .when('/datasets/:id/edit',
        templateUrl: 'partials/instruments/edit.html'
        controller: 'DatasetsEditController'
      )
  ]
)