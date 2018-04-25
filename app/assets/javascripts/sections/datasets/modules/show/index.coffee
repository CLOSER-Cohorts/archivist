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

      $scope.clusterMenuOptions = [
        [
          'Remove Topic',
          ($itemScope)->
            console.log 'Removing topic'
            console.log $itemScope
        ]
      ]

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

            $scope.current_cluster_selection = $scope.graphData.nodes.get data.nodes[0]
            console.log $scope

      $scope.loadNetworkData = (object)->
        $scope.current_cluster_selection =
          topic:
            name: ''
        nodes = new VisDataSet()
        edges = new VisDataSet()

        $scope.cluster = DataManager.getCluster(
          'Variable',
          object.id,
          true,
          (response)->
            groupings = {}
            for strand in $scope.cluster.strands
              for member in strand.members
                member.id += if member.type == 'Variable' then 20000000 else 10000000
                member.group = 'strand:' + strand.id.toString()
                member.borderWidth = if member.topic? then 3 else 1
                member.color =
                  border: if strand.good then 'black' else 'red'

                tooltip = '<span'
                tooltip += ' style="color: red;"' if not strand.good
                tooltip += '>' + member.text
                tooltip += '<br/>' + member.topic.name if member.topic?
                tooltip += '</span>'

                member.title = tooltip
                nodes.add member
                if member.sources?
                  for source in member.sources
                    edges.add {
                      from: member.id,
                      to: source.id + if source.type == 'Variable' then 20000000 else 10000000,
                      dashes: not source.interstrand
                    }
            console.log nodes
        )

        $scope.graphData =
          nodes: nodes,
          edges: edges

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
          variable.$add_mapping {
            sources:
              id: new_sources
              x: x
              y: y
          }
        console.log variable

      console.log $scope
  ]
)