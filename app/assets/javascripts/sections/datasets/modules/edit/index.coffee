edit = angular.module('archivist.datasets.edit',
  [
    'archivist.data_manager'
  ]
)

edit.controller(
  'DatasetsEditController',
  [
    '$http',
    '$scope',
    '$routeParams',
    '$location',
    'Flash',
    'DataManager'
    (
      $http,
      $scope,
      $routeParams,
      $location,
      Flash,
      DataManager
    )->
      $scope.dataset = DataManager.getDataset(
        $routeParams.id,
        {},
        ->
          $scope.page['title'] = $scope.dataset.name + ' | Edit'
          $scope.breadcrumbs = [
            {
              label: 'Datasets',
              link: '/datasets',
              active: false
            },
            {
              label: $scope.dataset.name,
              link: '/datasets/' + $scope.dataset.id,
              active: false
            },
            {
              label: 'Edit',
              link: false,
              active: true
            }
          ]
      )

      $http.get('/studies.json').success((data)->
        $scope.studies = data
      )

      $scope.updateDataset = ->
        $scope.dataset.$save(
          {}
        ,->
          Flash.add('success', 'Dataset updated successfully!')
          $location.path('/datasets')
          DataManager.clearCache()
        ,->
          Flash.add('error', 'Dataset could not be updated.')
        )
  ]
)