users = angular.module('archivist.users', [
  'archivist.flash'
])

users.controller(
  'UserController',
  [
    '$scope',
    '$location',
    '$http',
    '$route',
    'User',
    'DataManager',
    ($scope, $location, $http, $route, User, DataManager)->
      $scope.sign_in = (cred)->
        $scope.user.set('email', cred.email)
        $scope.user.sign_in(cred.password).then(->
          $location.path '/instruments'
        ,->
          $scope.publish_flash()
          cred.password = ""
          DataManager.clearCache()
          $route.reload()
          console.log 'User logged in.'
        )

      $scope.sign_up = (details)->
        $scope.user.set('email', details.email)
        $scope.user.set('first_name', details.fname)
        $scope.user.set('last_name', details.lname)
        $scope.user.set('group_id', details.group)
        $scope.user.sign_up(details.password, details.confirm).then(->
          $location.path '/instruments'
          true
        ,->
          $scope.publish_flash()
          details.password = ""
          details.confirm = ""
          DataManager.clearCache()
          $route.reload()
          false
        )

      $http.get('/user_groups/external.json').then (res)->
        $scope.sign_up_groups = res.data
      console.log $scope
  ]
)

users.factory(
  'User',
  [
    '$http',
    '$q',
    '$route',
    'Flash',
    'DataManager'
    ($http, $q, $route, Flash, DataManager)->
      class
        constructor: (@email)->
          @logged_in = false

        @attributes: [
          'email'
          'first_name'
          'last_name'
          'group',
          'group_id',
          'role'
        ]

        sign_in: (password)->
          self = this
          $http.post(
            '/users/sign_in.json',
            {
              user: {
                email: @email,
                password: password,
                remember_me: 1
              }
            }
          ).then(
            (res)->
              DataManager.clearCache()
              $route.reload()
              self.logged_in = true
              self.set 'first_name', res.data.first_name
              self.set 'last_name', res.data.last_name
              self.set 'group', res.data.group
              self.set 'role', res.data.role
              true
            ,(res)->
              self.logged_in = false
              Flash.add 'danger', res.data.error
              $q.reject res.data.error
          )

        sign_out: ->
          self = this
          $http.delete(
            '/users/sign_out.json'
          ).then(->
            DataManager.clearCache()
            $route.reload()
          ).finally ->
            self.logged_in = false

        sign_up: (password, confirmation)->
          self = this
          $http.post(
            '/users.json',
            {
              user: @get_all_data({
                password: password,
                password_confirmation: confirmation
              })
            }
          ).then(
            (res)->
              DataManager.clearCache()
              $route.reload()
              self.logged_in = true
              self.set 'role', res.data.role
            ,(res)->
              self.logged_in = false
              Flash.add 'danger', res.errors
          )

        is_admin: ->
          @get('role') == 'admin'

        is_editor: ->
          @get('role') == 'admin' || @get('role') == 'editor'

        get: (attribute)->
          @[attribute]

        set: (attribute, val)->
          @[attribute] = val

        get_all_data: (extra = {})->
          output = {}

          for attribute in @constructor.attributes
            output[attribute] = @get(attribute)

          for key of extra
            output[key] = extra[key]

          output
  ]
)
