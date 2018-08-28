(function() {
  var codes;

  codes = angular.module('archivist.data_manager.response_domains.codes', ['archivist.resource']);

  codes.factory('ResponseDomainCodes', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/response_domain_codes/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
