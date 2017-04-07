variablesInstrument = angular.module('archivist.data_manager.variables_instrument', [
  'archivist.resource'
])

variablesInstrument.factory(
  'VariablesInstrument',
  [
    'WrappedResource',
    (WrappedResource)->
      {
        all: new WrappedResource(
          'instruments/:id/variables.json',
          {id: '@id'}
        )

        clearCache: ->
          all.clearCache() if all?
      }
  ]
)
