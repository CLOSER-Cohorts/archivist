sequences = angular.module('archivist.data_manager.constructs.sequences', [
  'ngResource',
])

sequences.factory(
  'Sequences',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/cc_sequences/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        }
      )
  ]
)