(function() {
  var variables;

  variables = angular.module('archivist.data_manager.variables', ['archivist.resource']);

  variables.factory('Variables', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('datasets/:dataset_id/variables/:id.json', {
        id: '@id',
        dataset_id: '@dataset_id'
      }, {
        save: {
          method: 'PUT'
        },
        create: {
          method: 'POST'
        },
        update_topic: {
          method: 'POST',
          url: 'datasets/:dataset_id/variables/:id/set_topic.json'
        },
        split_mapping: {
          method: 'POST',
          url: 'datasets/:dataset_id/variables/:id/remove_source.json'
        },
        add_mapping: {
          method: 'POST',
          url: 'datasets/:dataset_id/variables/:id/add_sources.json'
        }
      });
    }
  ]);

}).call(this);
