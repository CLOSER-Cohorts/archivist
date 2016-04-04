loops = angular.module('archivist.data_manager.constructs.loops', [
  'ngResource',
])

loops.factory(
  'Loops',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/cc_loops/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        }
      )
  ]
)