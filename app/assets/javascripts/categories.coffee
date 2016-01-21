categories = angular.module('archivist.categories', [
  'archivist.resource'
])

categories.factory(
  'CategoriesArchive',
  [ 'WrappedResource',
    (WrappedResource)->
      new WrappedResource('instruments/:instrument_id/categories/:id.json', )
  ])
