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
            return console.log($scope);
          }
        }
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
          DataManager.addSources(variable, new_sources, x, y).then(function() {
            return $scope.model.orig_topic = $scope.model.topic;
          }, function(reason) {
            return variable.errors = reason.data.message;
          });
        }
        return console.log(variable);
      };
      return console.log($scope);
    }
  ]);

}).call(this);
