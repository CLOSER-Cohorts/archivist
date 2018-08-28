(function() {
  var loops;

  loops = angular.module('archivist.data_manager.constructs.loops', ['ngResource']);

  loops.factory('Loops', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/cc_loops/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      }, {
        save: {
          method: 'PUT'
        },
        create: {
          method: 'POST'
        },
        update_topic: {
          method: 'POST',
          url: 'instruments/:instrument_id/cc_loops/:id/set_topic.json'
        }
      });
    }
  ]);

}).call(this);
