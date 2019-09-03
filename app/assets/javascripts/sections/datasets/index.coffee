#= require_self
#= require ./modules

datasets = angular.module('archivist.datasets', [
  'templates',
  'ngRoute',
  'archivist.datasets.index',
  'archivist.datasets.show',
  'archivist.datasets.edit',
  'archivist.datasets.imports',
  'archivist.datasets.imports.show'
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
        templateUrl: 'partials/datasets/edit.html'
        controller: 'DatasetsEditController'
      )
      .when('/datasets/:id/imports',
        templateUrl: 'partials/datasets/imports/index.html'
        controller: 'DatasetsImportsController'
      )
      .when('/datasets/:dataset_id/imports/:id',
        templateUrl: 'partials/datasets/imports/show.html'
        controller: 'DatasetsImportsShowController'
      )
  ]
)
