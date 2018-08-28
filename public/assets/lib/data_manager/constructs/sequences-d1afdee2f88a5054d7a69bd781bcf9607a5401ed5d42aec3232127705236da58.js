(function() {
  var sequences;

  sequences = angular.module('archivist.data_manager.constructs.sequences', ['ngResource']);

  sequences.factory('Sequences', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/cc_sequences/:id.json', {
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
          url: 'instruments/:instrument_id/cc_sequences/:id/set_topic.json'
        }
      });
    }
  ]);

}).call(this);
