loops = angular.module('archivist.data_manager.constructs.loops', [
  'ngResource',
])

loops.factory(
  'Loops',
  [
    '$resource',
    ($resource)->
      $resource(
        'instruments/:instrument_id/cc_loops/:id.json'
        , {}
        , {
          query: {method: 'GET', isArray: true}
        }
      )
  ]
)