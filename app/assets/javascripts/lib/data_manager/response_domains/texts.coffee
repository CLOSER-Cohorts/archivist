texts = angular.module('archivist.data_manager.response_domains.texts', [
  'archivist.resource',
])

texts.factory(
  'ResponseDomainTexts',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/response_domain_texts/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        }
      )
  ]
)