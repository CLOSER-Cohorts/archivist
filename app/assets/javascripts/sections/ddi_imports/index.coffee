#= require_self
#= require ./modules

ddi_imports = angular.module('archivist.ddi_imports', [
  'templates',
  'ngRoute',
  'ngResource',
  'ui.bootstrap',
  'archivist.flash',
  'archivist.data_manager',
  'naif.base64'
])

ddi_imports.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/admin/imports/:id',
        templateUrl: 'partials/ddi_imports/show.html'
        controller: 'DdiImportsShowController'
      )
])

ddi_imports.controller(
  'DdiImportsController',
  [
    '$scope',
    '$routeParams',
    'VisDataSet',
    'DataManager'
    (
      $scope,
      $routeParams,
      VisDataSet,
      DataManager
    )->
      $scope.imports = DataManager.getDdiImports()
  ]
)

ddi_imports.controller(
  'DdiImportsShowController',
  [
    '$scope',
    '$routeParams',
    'VisDataSet',
    'DataManager'
    (
      $scope,
      $routeParams,
      VisDataSet,
      DataManager
    )->
      $scope.import = DataManager.getDdiImport(
        {
          id: $routeParams.id
        },
        {},
        ->
          $scope.page['title'] = 'Imports'
          $scope.breadcrumbs = [
            {
              label: 'Imports',
              link: '/ddi_imports',
              active: false
            },
            {
              label: $routeParams.id,
              link: false,
              active: true
            }
          ]
      )
  ]
)


ddi_imports.factory('Base64Factory',
  [
    '$q',
    ($q)->
      {
        getBase64: (file) ->
          deferred = $q.defer()
          readerMapping = new FileReader
          readerMapping.readAsDataURL file

          readerMapping.onload = ->
            deferred.resolve readerMapping.result
            return

          readerMapping.onerror = (error) ->
            deferred.reject error
            return

          deferred.promise
      }
])
