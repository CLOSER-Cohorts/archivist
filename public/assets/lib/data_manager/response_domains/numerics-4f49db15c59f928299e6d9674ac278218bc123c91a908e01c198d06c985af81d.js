(function() {
  var numerics;

  numerics = angular.module('archivist.data_manager.response_domains.numerics', ['archivist.resource']);

  numerics.factory('ResponseDomainNumerics', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/response_domain_numerics/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
