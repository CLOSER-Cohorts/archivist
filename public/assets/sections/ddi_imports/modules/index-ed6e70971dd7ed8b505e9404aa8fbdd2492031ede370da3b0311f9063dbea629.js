(function() {
  var ddi_imports;

  ddi_imports = angular.module('archivist.ddi_imports', ['ngVis', 'archivist.data_manager']);

  ddi_imports.controller('DdiImportsController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      return $scope.imports = DataManager.getDdiImports();
    }
  ]);

}).call(this);
