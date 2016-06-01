admin = angular.module('archivist.data_manager.users.admin', [
  'archivist.resource'
])

admin.factory(
  'UserAdmin',
  [ 'GetResource',
    (GetResource)->
      GetResource('users.json',{})
  ]
)
