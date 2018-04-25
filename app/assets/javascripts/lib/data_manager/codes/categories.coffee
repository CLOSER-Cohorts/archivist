categories = angular.module('archivist.data_manager.codes.categories', [
  'archivist.resource'
])

categories.factory(
  'Categories',
  [ 'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/categories/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        }
      )
  ])
