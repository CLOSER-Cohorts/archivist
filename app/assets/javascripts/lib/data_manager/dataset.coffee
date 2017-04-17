datasets = angular.module('archivist.data_manager.datasets', [
  'archivist.resource'
])

datasets.factory(
  'Datasets',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'datasets/:id.json',
        {id: '@id'},
        {
          save: {
            method: 'PUT'
          },
          create: {
            method: 'POST'
          }
        }
      )
  ]
)