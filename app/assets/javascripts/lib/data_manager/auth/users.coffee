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
        },
        {
          save: {method: 'PUT'},
          create: {method: 'POST'}
          reset_password: {method: 'POST', url: 'users/admin/:id/password.json'}
        }
      )
  ])
