numerics = angular.module('archivist.data_manager.response_domains.numerics', [
  'archivist.resource',
])

numerics.factory(
  'Numerics',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/response_domain_numerics/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        }
      )
  ]
)