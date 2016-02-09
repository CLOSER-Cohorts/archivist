code_lists = angular.module('archivist.code_lists', [
  'archivist.resource',
])

code_lists.factory(
  'CodeListsArchive',
  [ 'WrappedResource',
    (
      WrappedResource,
    )->
      new WrappedResource 'instruments/:instrument_id/code_lists/:id.json'
        ,{id: '@id', instrument_id: '@instrument_id'}
  ])