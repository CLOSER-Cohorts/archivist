variables = angular.module('archivist.data_manager.variables', [
  'archivist.resource'
])

variables.factory(
  'Variables',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'datasets/:dataset_id/variables/:id.json',
        {
          id: '@id',
          dataset_id: '@dataset_id'
        },
        {
          save: {method: 'PUT'},
          create: {method: 'POST'}
        }
      )
  ]
)