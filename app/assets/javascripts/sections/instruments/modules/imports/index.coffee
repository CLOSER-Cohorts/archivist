imports = angular.module('archivist.instrument_imports',
  [
    'ngVis',
    'archivist.data_manager'
  ]
)

imports.controller(
  'InstrumentsImportsController',
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
      $scope.instrument = DataManager.getInstrument(
        $routeParams.id,
        {},
        ->
          $scope.page['title'] = $scope.instrument.name + ' | Edit'
          $scope.breadcrumbs = [
            {
              label: 'Instruments',
              link: '/admin/instruments',
              active: false
            },
            {
              label: $scope.instrument.name,
              link: '/instruments/' + $scope.instrument.id,
              active: false
            },
            {
              label: 'Imports',
              link: false,
              active: true
            }
          ]
      )
      $scope.imports = DataManager.getInstrumentImports(instrument_id: $routeParams.id)
  ]
)
