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
