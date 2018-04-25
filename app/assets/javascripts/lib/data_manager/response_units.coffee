conditions = angular.module('archivist.data_manager.response_units', [
  'archivist.resource',
])

conditions.factory(
  'ResponseUnits',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/response_units/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        }
      )
  ]
)