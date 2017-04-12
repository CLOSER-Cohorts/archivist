variablesInstrument = angular.module('archivist.data_manager.variables_instrument', [
  'archivist.resource'
])

variablesInstrument.factory(
  'VariablesInstrument',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/variables/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        }
      )
  ]
)
