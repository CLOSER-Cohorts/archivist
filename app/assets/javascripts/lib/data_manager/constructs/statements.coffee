statements = angular.module('archivist.data_manager.constructs.statements', [
  'ngResource',
])

statements.factory(
  'Statements',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/cc_statements/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        }
      )
  ]
)