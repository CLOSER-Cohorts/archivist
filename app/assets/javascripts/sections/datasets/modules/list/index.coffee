index = angular.module('archivist.datasets.index',
  [
    'archivist.data_manager'
  ]
)

index.controller(
  'DatasetsIndexController',
  [
    '$scope',
    '$http',
    'DataManager',
    (
      $scope,
      $http,
      DataManager
    )->
      $scope.datasets = DataManager.getDatasets()
      $scope.pageSize = 24
      $scope.currentPage = 1
      $scope.filterStudy = (study)->
        $scope.filteredStudy = study

      $http.get('/studies.json').success((data)->
        $scope.studies = data
      )

      console.log $scope
  ]
)
