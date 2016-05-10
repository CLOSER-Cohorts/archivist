users = angular.module('archivist.users', [
  'archivist.flash'
])

users.controller(
  'UserController',
  [
    '$scope',
    '$location',
    'User',
    ($scope, $location, User)->
      $scope.sign_in = (cred)->
        $scope.user.set('email', cred.email)
        $scope.user.sign_in(cred.password).then(->
            $location.path '/instruments'
        ,->
          $scope.publish_flash
          cred.password = ""
        )
  ]
)

users.factory(
  'User',
  [
    '$http',
    'Flash'
    ($http, Flash)->
      class
        constructor: (@email)->
          @logged_in = false

        @attributes: [
          'email'
          'first_name'
          'last_name'
          'group',
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
              self.logged_in = true
              self.set 'first_name', res.data.first_name
              self.set 'last_name', res.data.last_name
              self.set 'group', res.data.group
              self.set 'role', res.data.role
            ,(res)->
              self.logged_in = false
              Flash.add 'danger', res.data.error
          )

        sign_out: ->
          self = this
          $http.delete(
            '/users/sign_out.json'
          ).finally ->
            self.logged_in = false

        sign_up: (password, confirmation)->
          $http.post(
            '/users.json',
            {
              user: @get_all_data({
                password: password,
                password_confirmation: confirmation
              })
            }
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