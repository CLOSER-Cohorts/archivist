users = angular.module('archivist.data_manager.auth.users', [
  'archivist.resource'
])

users.factory(
  'Users',
  [ 'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'users/admin/:id.json',
        {
          id: '@id'
        }
      )
  ])
