dataset_imports = angular.module('archivist.data_manager.dataset_imports', [
  'ngResource',
])

dataset_imports.factory(
  'DatasetImports',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'datasets/:dataset_id/imports/:id.json',
        {
          id: '@id',
          dataset_id: '@dataset_id'
        },
        {
          save:           {method: 'PUT'},
          create:         {method: 'POST'}
        }
      )
  ]
)
