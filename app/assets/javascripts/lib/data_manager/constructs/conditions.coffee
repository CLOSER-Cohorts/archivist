conditions = angular.module('archivist.data_manager.constructs.conditions', [
  'ngResource',
])

conditions.factory(
  'Conditions',
  [
    '$resource',
    ($resource)->
      $resource(
        'instruments/:instrument_id/cc_conditions/:id.json'
        , {}
        , {
          query: {method: 'GET', isArray: true}
        }
      )
  ]
)