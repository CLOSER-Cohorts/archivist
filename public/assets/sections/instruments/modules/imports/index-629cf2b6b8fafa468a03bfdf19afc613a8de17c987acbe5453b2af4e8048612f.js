(function() {
  var imports;

  imports = angular.module('archivist.instrument_imports', ['ngVis', 'archivist.data_manager']);

  imports.controller('InstrumentsImportsController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      $scope.instrument = DataManager.getInstrument($routeParams.id, {}, function() {
        $scope.page['title'] = $scope.instrument.name + ' | Edit';
        return $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/admin/instruments',
            active: false
          }, {
            label: $scope.instrument.name,
            link: '/instruments/' + $scope.instrument.id,
            active: false
          }, {
            label: 'Imports',
            link: false,
            active: true
          }
        ];
      });
      return $scope.imports = DataManager.getInstrumentImports({
        instrument_id: $routeParams.id
      });
    }
  ]);

}).call(this);
