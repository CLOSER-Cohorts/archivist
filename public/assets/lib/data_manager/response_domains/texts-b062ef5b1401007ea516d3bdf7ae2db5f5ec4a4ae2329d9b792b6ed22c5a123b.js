(function() {
  var texts;

  texts = angular.module('archivist.data_manager.response_domains.texts', ['archivist.resource']);

  texts.factory('ResponseDomainTexts', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/response_domain_texts/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
