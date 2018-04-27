auth = angular.module('archivist.data_manager.auth', [
  'archivist.data_manager.auth.groups',
  'archivist.data_manager.auth.users',
])

auth.factory(
  'Auth',
  [
    'Groups',
    'Users',
    (
      Groups,
      Users
    )->
      Auth = {}

      Auth.Groups        = Groups
      Auth.Users         = Users

      Auth.clearCache = ->
        Auth.Groups.clearCache()
        Auth.Users.clearCache()

      Auth
  ]
)