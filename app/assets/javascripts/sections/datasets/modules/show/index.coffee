show = angular.module('archivist.datasets.show',
  [
    'archivist.data_manager'
  ]
)

show.controller(
  'DatasetsShowController',
  [
    '$scope',
    '$routeParams',
    'DataManager',
    (
      $scope,
      $routeParams,
      DataManager
    )->
      $scope.dataset = DataManager.getDataset(
        $routeParams.id,
        {
          variables: true
        },
        ->
          $scope.breadcrumbs = [
            {
              label: 'Datasets',
              link: '/datasets',
              active: false
            },
            {
              label: $scope.dataset.name,
              link: false,
              active: true
            }
          ]
      )
      $scope.pageSize = 20
      console.log $scope
  ]
)