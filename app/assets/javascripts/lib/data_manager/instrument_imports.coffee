instrument_imports = angular.module('archivist.data_manager.instrument_imports', [
  'ngResource',
])

instrument_imports.factory(
  'InstrumentImports',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/imports/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        },
        {
          save:           {method: 'PUT'},
          create:         {method: 'POST'}
        }
      )
  ]
)
