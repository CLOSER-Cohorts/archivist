(function() {
  var code_lists;

  code_lists = angular.module('archivist.data_manager.codes.code_lists', ['archivist.resource']);

  code_lists.factory('CodeLists', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/code_lists/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
