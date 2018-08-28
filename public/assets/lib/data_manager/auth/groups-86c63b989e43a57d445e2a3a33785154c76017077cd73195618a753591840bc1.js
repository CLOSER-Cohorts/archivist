(function() {
  var groups;

  groups = angular.module('archivist.data_manager.auth.groups', ['archivist.resource']);

  groups.factory('Groups', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('user_groups/:id.json', {
        id: '@id'
      });
    }
  ]);

}).call(this);
