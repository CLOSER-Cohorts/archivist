ddi_imports = angular.module('archivist.ddi_imports',
  [
    'ngVis',
    'archivist.data_manager'
  ]
)

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
