show = angular.module('archivist.datasets.show',
  [
    'ngVis',
    'archivist.data_manager'
  ]
)

show.controller(
  'DatasetsShowController',
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
        $routeParams.id,
        {
          variables: true,
          questions: true
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
      $scope.currentPage = 1

      $scope.graphData    = {}
      $scope.graphOptions =
        interaction:
          dragNodes: false
        layout:
          hierarchical:
            enabled: true
            direction: 'LR'

      $scope.graphEvents  =
        click: (data)->
          if data.nodes.length == 1
            if data.nodes[0] < 20000000
              type = 'CcQuestion'
              id = data.nodes[0] - 10000000
            else
              type = 'Variable'
              id = data.nodes[0] - 20000000

            console.log $scope

      $scope.split_mapping = (model, other, x = null, y = null)->
        model.$split_mapping {
          other:
            class: other.class
            id:    other.id
          x: x
          y: y
        }

      $scope.detectKey = (event, variable, x = null, y = null)->
        if event.keyCode == 13
          new_sources = event.target.value.split ','
          DataManager.addSources(variable, new_sources, x, y).then(->
            $scope.model.orig_topic = $scope.model.topic
          , (reason)->
            variable.errors = reason.data.message
          )
        console.log variable

      console.log $scope
  ]
)
