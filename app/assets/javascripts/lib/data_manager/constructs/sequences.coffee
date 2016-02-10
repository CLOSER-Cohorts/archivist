sequences = angular.module('archivist.data_manager.constructs.sequences', [
  'ngResource',
])

sequences.factory(
  'Sequences',
  [
    '$resource',
    ($resource)->
      $resource(
        'instruments/:instrument_id/cc_sequences/:id.json'
        , {}
        , {
          query: {method: 'GET', isArray: true}
        }
      )
  ]
)