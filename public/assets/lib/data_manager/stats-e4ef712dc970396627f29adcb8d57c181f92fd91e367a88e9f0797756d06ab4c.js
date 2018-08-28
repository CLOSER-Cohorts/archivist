(function() {
  var stats;

  stats = angular.module('archivist.data_manager.stats', []);

  stats.factory('ApplicationStats', [
    '$http', function($http) {
      return $http.get('/stats.json', {
        cache: true
      });
    }
  ]);

  stats.factory('InstrumentStats', [
    '$http', function($http) {
      return function(id) {
        return $http.get('/instruments/' + id + '/stats.json', {
          cache: true
        });
      };
    }
  ]);

}).call(this);
