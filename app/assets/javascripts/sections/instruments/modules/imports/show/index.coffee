show = angular.module('archivist.instrument_imports.show',
  [
    'ngVis',
    'archivist.data_manager'
  ]
)

show.controller(
  'InstrumentsImportsShowController',
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
        $routeParams.instrument_id,
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
              link: '/instruments/' + $scope.instrument.id + '/imports',
              active: false
            },
            {
              label: $routeParams.id,
              link: false,
              active: true
            }
          ]
      )
      $scope.import = DataManager.getInstrumentImport(instrument_id: $routeParams.instrument_id, id: $routeParams.id)
  ]
)
