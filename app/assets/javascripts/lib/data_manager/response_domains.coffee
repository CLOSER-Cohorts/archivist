rds = angular.module('archivist.data_manager.response_domains', [
  'archivist.resource'
])

rds.factory(
  'ResponseDomains',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:id/response_domains.json',
        {id: '@id'}
      )
  ]
)