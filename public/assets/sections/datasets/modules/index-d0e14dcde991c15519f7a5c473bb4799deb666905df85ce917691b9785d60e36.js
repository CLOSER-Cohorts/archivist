(function() {
  var index;

  index = angular.module('archivist.datasets.index', ['archivist.data_manager']);

  index.controller('DatasetsIndexController', [
    '$scope', '$http', 'DataManager', function($scope, $http, DataManager) {
      $scope.datasets = DataManager.getDatasets();
      $scope.pageSize = 24;
      $scope.currentPage = 1;
      $scope.filterStudy = function(study) {
        return $scope.filteredStudy = study;
      };
      $http.get('/studies.json').success(function(data) {
        return $scope.studies = data;
      });
      return console.log($scope);
    }
  ]);

}).call(this);
(function() {
  var show;

  show = angular.module('archivist.datasets.show', ['ngVis', 'archivist.data_manager']);

  show.controller('DatasetsShowController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      $scope.dataset = DataManager.getDataset($routeParams.id, {
        variables: true,
        questions: true
      }, function() {
        return $scope.breadcrumbs = [
          {
            label: 'Datasets',
            link: '/datasets',
            active: false
          }, {
            label: $scope.dataset.name,
            link: false,
            active: true
          }
        ];
      });
      $scope.pageSize = 20;
      $scope.clusterMenuOptions = [
        [
          'Remove Topic', function($itemScope) {
            console.log('Removing topic');
            return console.log($itemScope);
          }
        ]
      ];
      $scope.graphData = {};
      $scope.graphOptions = {
        interaction: {
          dragNodes: false
        },
        layout: {
          hierarchical: {
            enabled: true,
            direction: 'LR'
          }
        }
      };
      $scope.graphEvents = {
        click: function(data) {
          var id, type;
          if (data.nodes.length === 1) {
            if (data.nodes[0] < 20000000) {
              type = 'CcQuestion';
              id = data.nodes[0] - 10000000;
            } else {
              type = 'Variable';
              id = data.nodes[0] - 20000000;
            }
            $scope.current_cluster_selection = $scope.graphData.nodes.get(data.nodes[0]);
            return console.log($scope);
          }
        }
      };
      $scope.loadNetworkData = function(object) {
        var edges, nodes;
        $scope.current_cluster_selection = {
          topic: {
            name: ''
          }
        };
        nodes = new VisDataSet();
        edges = new VisDataSet();
        $scope.cluster = DataManager.getCluster('Variable', object.id, true, function(response) {
          var groupings, i, j, k, len, len1, len2, member, ref, ref1, ref2, source, strand, tooltip;
          groupings = {};
          ref = $scope.cluster.strands;
          for (i = 0, len = ref.length; i < len; i++) {
            strand = ref[i];
            ref1 = strand.members;
            for (j = 0, len1 = ref1.length; j < len1; j++) {
              member = ref1[j];
              member.id += member.type === 'Variable' ? 20000000 : 10000000;
              member.group = 'strand:' + strand.id.toString();
              member.borderWidth = member.topic != null ? 3 : 1;
              member.color = {
                border: strand.good ? 'black' : 'red'
              };
              tooltip = '<span';
              if (!strand.good) {
                tooltip += ' style="color: red;"';
              }
              tooltip += '>' + member.text;
              if (member.topic != null) {
                tooltip += '<br/>' + member.topic.name;
              }
              tooltip += '</span>';
              member.title = tooltip;
              nodes.add(member);
              if (member.sources != null) {
                ref2 = member.sources;
                for (k = 0, len2 = ref2.length; k < len2; k++) {
                  source = ref2[k];
                  edges.add({
                    from: member.id,
                    to: source.id + (source.type === 'Variable' ? 20000000 : 10000000),
                    dashes: !source.interstrand
                  });
                }
              }
            }
          }
          return console.log(nodes);
        });
        return $scope.graphData = {
          nodes: nodes,
          edges: edges
        };
      };
      $scope.split_mapping = function(model, other, x, y) {
        if (x == null) {
          x = null;
        }
        if (y == null) {
          y = null;
        }
        return model.$split_mapping({
          other: {
            "class": other["class"],
            id: other.id
          },
          x: x,
          y: y
        });
      };
      $scope.detectKey = function(event, variable, x, y) {
        var new_sources;
        if (x == null) {
          x = null;
        }
        if (y == null) {
          y = null;
        }
        if (event.keyCode === 13) {
          new_sources = event.target.value.split(',');
          variable.$add_mapping({
            sources: {
              id: new_sources,
              x: x,
              y: y
            }
          });
        }
        return console.log(variable);
      };
      return console.log($scope);
    }
  ]);

}).call(this);
(function() {
  var edit;

  edit = angular.module('archivist.datasets.edit', ['archivist.data_manager']);

  edit.controller('DatasetsEditController', [
    '$http', '$scope', '$routeParams', '$location', 'Flash', 'DataManager', function($http, $scope, $routeParams, $location, Flash, DataManager) {
      $scope.dataset = DataManager.getDataset($routeParams.id, {}, function() {
        $scope.page['title'] = $scope.dataset.name + ' | Edit';
        return $scope.breadcrumbs = [
          {
            label: 'Datasets',
            link: '/datasets',
            active: false
          }, {
            label: $scope.dataset.name,
            link: '/datasets/' + $scope.dataset.id,
            active: false
          }, {
            label: 'Edit',
            link: false,
            active: true
          }
        ];
      });
      $http.get('/studies.json').success(function(data) {
        return $scope.studies = data;
      });
      return $scope.updateDataset = function() {
        return $scope.dataset.$save({}, function() {
          Flash.add('success', 'Dataset updated successfully!');
          $location.path('/datasets');
          return DataManager.clearCache();
        }, function() {
          return Flash.add('error', 'Dataset could not be updated.');
        });
      };
    }
  ]);

}).call(this);
(function() {


}).call(this);
