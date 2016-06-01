groups = angular.module('archivist.data_manager.users.groups', [
  'archivist.resource'
])

groups.factory(
  'Groups',
  [ 'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'groups/:id.json',
        {
          id: '@id'
        }
      )
  ])
