code_lists = angular.module('archivist.data_manager.codes.code_lists', [
  'archivist.resource',
])

code_lists.factory(
  'CodeLists',
  [ 'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/code_lists/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        }
      )
  ])