show = angular.module('archivist.datasets.imports.show',
  [
    'ngVis',
    'archivist.data_manager'
  ]
)

show.controller(
  'DatasetsImportsShowController',
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
      $scope.dataset = DataManager.getDataset(
        $routeParams.dataset_id,
        {},
        ->
          $scope.page['title'] = $scope.dataset.name + ' | Edit'
          $scope.breadcrumbs = [
            {
              label: 'Datasets',
              link: '/admin/datasets',
              active: false
            },
            {
              label: $scope.dataset.name,
              link: '/datasets/' + $scope.dataset.id,
              active: false
            },
            {
              label: 'Imports',
              link: '/datasets/' + $scope.dataset.id + '/imports',
              active: false
            },
            {
              label: $routeParams.id,
              link: false,
              active: true
            }
          ]
      )
      $scope.import = DataManager.getDatasetImportsx(dataset_id: $routeParams.dataset_id, id: $routeParams.id)
  ]
)
