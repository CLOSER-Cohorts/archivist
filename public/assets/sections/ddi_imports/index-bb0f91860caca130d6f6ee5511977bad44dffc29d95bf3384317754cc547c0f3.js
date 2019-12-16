(function() {
  var ddi_imports;

  ddi_imports = angular.module('archivist.ddi_imports', ['templates', 'ngRoute', 'ngResource', 'ui.bootstrap', 'archivist.flash', 'archivist.data_manager', 'naif.base64']);

  ddi_imports.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/admin/imports/:id', {
        templateUrl: 'partials/ddi_imports/show.html',
        controller: 'DdiImportsShowController'
      });
    }
  ]);

  ddi_imports.controller('DdiImportsController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      return $scope.imports = DataManager.getDdiImports();
    }
  ]);

  ddi_imports.controller('DdiImportsShowController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      return $scope["import"] = DataManager.getDdiImport({
        id: $routeParams.id
      }, {}, function() {
        $scope.page['title'] = 'Imports';
        return $scope.breadcrumbs = [
          {
            label: 'Imports',
            link: '/ddi_imports',
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

  ddi_imports.factory('Base64Factory', [
    '$q', function($q) {
      return {
        getBase64: function(file) {
          var deferred, readerMapping;
          deferred = $q.defer();
          readerMapping = new FileReader;
          readerMapping.readAsDataURL(file);
          readerMapping.onload = function() {
            deferred.resolve(readerMapping.result);
          };
          readerMapping.onerror = function(error) {
            deferred.reject(error);
          };
          return deferred.promise;
        }
      };
    }
  ]);

}).call(this);
(function() {
  var ddi_imports;

  ddi_imports = angular.module('archivist.ddi_imports', ['ngVis', 'archivist.data_manager']);

  ddi_imports.controller('DdiImportsController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      return $scope.imports = DataManager.getDdiImports();
    }
  ]);

}).call(this);
