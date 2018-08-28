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
