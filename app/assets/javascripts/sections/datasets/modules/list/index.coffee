index = angular.module('archivist.datasets.index',
  [
    'archivist.data_manager'
  ]
)

index.controller(
  'DatasetsIndexController',
  [
    '$scope',
    'DataManager',
    (
      $scope,
      DataManager
    )->
      $scope.datasets = DataManager.getDatasets()
      $scope.pageSize = 20
      console.log $scope
  ]
)