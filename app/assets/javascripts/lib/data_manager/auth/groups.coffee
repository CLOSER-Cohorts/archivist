groups = angular.module('archivist.data_manager.auth.groups', [
  'archivist.resource'
])

groups.factory(
  'Groups',
  [ 'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'user_groups/:id.json',
        {
          id: '@id'
        }
      )
  ])
