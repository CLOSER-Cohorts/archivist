(function() {
  var datasets;

  datasets = angular.module('archivist.data_manager.datasets', ['archivist.resource']);

  datasets.factory('Datasets', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('datasets/:id.json', {
        id: '@id'
      }, {
        save: {
          method: 'PUT'
        },
        create: {
          method: 'POST'
        }
      });
    }
  ]);

}).call(this);
