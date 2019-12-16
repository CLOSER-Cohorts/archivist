(function() {
  var show;

  show = angular.module('archivist.ddi_imports.show', ['ngVis', 'archivist.data_manager']);

  show.controller('DdiImportsShowController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      return $scope["import"] = DataManager.getDdiImport({
        id: $routeParams.id
      }, {}, function() {
        $scope.page['title'] = 'Import';
        return $scope.breadcrumbs = [
          {
            label: 'Imports',
            link: '/admin/imports',
            active: false
          }, {
            label: $routeParams.id,
            link: false,
            active: true
          }
        ];
      });
    }
  ]);

}).call(this);
