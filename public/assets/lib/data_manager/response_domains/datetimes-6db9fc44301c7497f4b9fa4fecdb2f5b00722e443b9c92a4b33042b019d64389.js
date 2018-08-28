(function() {
  var datetimes;

  datetimes = angular.module('archivist.data_manager.response_domains.datetimes', ['archivist.resource']);

  datetimes.factory('ResponseDomainDatetimes', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/response_domain_datetimes/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
