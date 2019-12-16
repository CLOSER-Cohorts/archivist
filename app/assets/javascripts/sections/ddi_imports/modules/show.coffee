show = angular.module('archivist.ddi_imports.show',
  [
    'ngVis',
    'archivist.data_manager'
  ]
)

show.controller(
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
          $scope.page['title'] = 'Import'
          $scope.breadcrumbs = [
            {
              label: 'Imports',
              link: '/admin/imports',
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
