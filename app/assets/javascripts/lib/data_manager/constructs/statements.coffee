statements = angular.module('archivist.data_manager.constructs.statements', [
  'ngResource',
])

statements.factory(
  'Statements',
  [
    '$resource',
    ($resource)->
      $resource(
        'instruments/:instrument_id/cc_statements/:id.json'
        , {}
        , {
          query: {method: 'GET', isArray: true}
        }
      )
  ]
)