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
