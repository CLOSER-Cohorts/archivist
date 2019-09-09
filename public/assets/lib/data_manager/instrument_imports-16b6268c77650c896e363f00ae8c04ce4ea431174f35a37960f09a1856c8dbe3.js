(function() {
  var instrument_imports;

  instrument_imports = angular.module('archivist.data_manager.instrument_imports', ['ngResource']);

  instrument_imports.factory('InstrumentImports', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/imports/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
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
