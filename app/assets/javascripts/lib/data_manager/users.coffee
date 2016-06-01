users = angular.module('archivist.data_manager.users', [
  'archivist.data_manager.users.groups',
  'archivist.data_manager.users.admin',
])

users.factory(
  'Users',
  [
    'Groups',
    'UserAdmin',
    (
      Groups,
      Admin
    )->
      Users = {}

      Users.Groups        = Groups
      Users.Admin         = Admin

      Users.clearCache = ->
        Users.Groups.clearCache()

      Users
  ]
)