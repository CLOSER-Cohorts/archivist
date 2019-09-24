(function() {
  var datasets;

  datasets = angular.module('archivist.datasets', ['templates', 'ngRoute', 'archivist.datasets.index', 'archivist.datasets.show', 'archivist.datasets.edit', 'archivist.datasets.imports', 'archivist.datasets.imports.show']);

  datasets.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/datasets', {
        templateUrl: 'partials/datasets/index.html',
        controller: 'DatasetsIndexController'
      }).when('/datasets/:id', {
        templateUrl: 'partials/datasets/show.html',
        controller: 'DatasetsShowController'
      }).when('/datasets/:id/edit', {
        templateUrl: 'partials/datasets/edit.html',
        controller: 'DatasetsEditController'
      }).when('/datasets/:id/imports', {
        templateUrl: 'partials/datasets/imports/index.html',
        controller: 'DatasetsImportsController'
      }).when('/datasets/:dataset_id/imports/:id', {
        templateUrl: 'partials/datasets/imports/show.html',
        controller: 'DatasetsImportsShowController'
      });
    }
  ]);

}).call(this);
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
  var imports;

  imports = angular.module('archivist.datasets.imports', ['ngVis', 'archivist.data_manager']);

  imports.controller('DatasetsImportsController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      $scope.dataset = DataManager.getDataset($routeParams.id, {}, function() {
        $scope.page['title'] = $scope.dataset.name + ' | Edit';
        return $scope.breadcrumbs = [
          {
            label: 'Datasets',
            link: '/admin/datasets',
            active: false
          }, {
            label: $scope.dataset.name,
            link: '/datasets/' + $scope.dataset.id,
            active: false
          }, {
            label: 'Imports',
            link: false,
            active: true
          }
        ];
      });
      return $scope.imports = DataManager.getDatasetImports({
        dataset_id: $routeParams.id
      });
    }
  ]);

}).call(this);
(function() {
  var show;

  show = angular.module('archivist.datasets.imports.show', ['ngVis', 'archivist.data_manager']);

  show.controller('DatasetsImportsShowController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      $scope.dataset = DataManager.getDataset($routeParams.dataset_id, {}, function() {
        $scope.page['title'] = $scope.dataset.name + ' | Edit';
        return $scope.breadcrumbs = [
          {
            label: 'Datasets',
            link: '/admin/datasets',
            active: false
          }, {
            label: $scope.dataset.name,
            link: '/datasets/' + $scope.dataset.id,
            active: false
          }, {
            label: 'Imports',
            link: '/datasets/' + $scope.dataset.id + '/imports',
            active: false
          }, {
            label: $routeParams.id,
            link: false,
            active: true
          }
        ];
      });
      return $scope["import"] = DataManager.getDatasetImportsx({
        dataset_id: $routeParams.dataset_id,
        id: $routeParams.id
      });
    }
  ]);

}).call(this);
(function() {


}).call(this);
