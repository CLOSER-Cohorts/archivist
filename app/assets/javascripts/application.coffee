# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require jquery-ui/jquery-ui
#= require angular/angular
#= require angular-route/angular-route
#= require angular-messages/angular-messages
#= require angular-resource/angular-resource
#= require angular-rails-templates
#= require angular-bootstrap/ui-bootstrap-tpls
#= require angular-ui-sortable/sortable
#= require bootstrap-sass-official/assets/javascripts/bootstrap-sprockets
#= require socket.io-client/socket.io
#
#= require lib
#= require sections
#= require_tree ./templates/

archivist = angular.module('archivist', [
  'templates',
  'ngRoute',
  'ui.sortable',
  'archivist.flash',
  'archivist.instruments',
  'archivist.build',
  'archivist.summary',
  'archivist.admin',
  'archivist.realtime',
  'archivist.users',
  'archivist.data_manager'
])

archivist.config([ '$routeProvider', '$locationProvider',
  ($routeProvider, $locationProvider)->
    $routeProvider
      .when('/',
        templateUrl: 'index.html'
        controller: 'RootController'
      )
    $locationProvider.html5Mode true
])

archivist.controller('RootController',
  [
    '$scope',
    '$location',
    'DataManager'
    'User',
  ($scope, $location, DataManager, User)->
    $scope.softwareName = 'Archivist'
    $scope.softwareVersion = window.app_version
    $scope.page['title'] = 'Home'
    $scope.isActive = (viewLocation) ->
      viewLocation == $location.path()

    $scope.user = new User(window.current_user_email)
    if $scope.user.email.length > 0
      $scope.user.sign_in()

    $scope.sign_out = ->
      $scope.user.sign_out().finally ->
        DataManager.clearCache()
])

archivist.directive 'notices', ->
  {
    templateUrl: 'partials/notices.html'
  }

archivist.directive 'breadcrumb', ->
  {
    templateUrl: 'partials/breadcrumb.html'
  }

archivist.directive 'ngFileModel', [
  '$parse'
  ($parse) ->
    {
      restrict: 'A'
      link: (scope, element, attrs) ->
        model = $parse(attrs.ngFileModel)
        isMultiple = attrs.multiple
        modelSetter = model.assign
        element.bind 'change', ->
          values = []
          angular.forEach element[0].files, (item) ->
            values.push item

          scope.$apply ->
            if isMultiple
              modelSetter scope, values
            else
              modelSetter scope, values[0]

    }
]

archivist.run(['$rootScope', 'Flash', 'RealTimeConnection'
  ($rootScope, Flash, RealTimeConnection)->
    Array::unique = ->
      output = {}
      output[@[key]] = @[key] for key in [0...@length]
      value for key, value of output

    Array::select_resource_by_id = (ref_id)->
      output = (@[key] for key in [0...@length] when @[key].id == ref_id)[0]

    Array::get_index_by_id = (ref_id)->
      (key for key in [0...@length] when @[key].id == ref_id)[0]

    Array::select_resource_by_id_and_type = (ref_id, ref_type)->
      output = (@[key] for key in [0...@length] when @[key].id == ref_id and @[key].type == ref_type)[0]

    Array::get_index_by_id_and_type = (ref_id, ref_type)->
      (key for key in [0...@length] when @[key].id == ref_id and @[key].type == ref_type)[0]

    Object.lower_everything = (obj)->
      target = {}
      for k of obj
        if obj.hasOwnProperty k
          if typeof k == "string"
            target[k.toLowerCase()] = if typeof obj[k] == 'string' then obj[k].toLowerCase() else obj[k]
          else
            target[k] = if typeof obj[k] == 'string' then obj[k].toLowerCase() else obj[k]
      target

    String::replaceAll = (search, replacement) ->
      target = this
      target.replace(new RegExp(search, 'g'), replacement)

    String::pascal_case_to_underscore = ->
      target = this
      target.replace(/([A-Z])/g, (x,y) -> "_"+y.toLowerCase()).replace /^_/, ''

    String::underscore_to_pascal_case = ->
      target = this.capitalizeFirstLetter()
      target.replace /_(.)/g, (x,y) -> y.toUpperCase()


    String::capitalizeFirstLetter = ->
      target = this
      target.charAt(0).toUpperCase() + target.slice(1)

    Flash.set_scope $rootScope

    $rootScope.publish_flash = ->
      Flash.publish($rootScope)

    $rootScope.$on('$routeChangeSuccess', ->
      $rootScope.publish_flash()
    )
    $rootScope.publish_flash()

    $rootScope.page = {title: 'Home'}

    $rootScope.realtimeStatus = false

    $rootScope.range = (i)->
      (num for num in [1..i])
])

archivist.filter 'capitalize', ->
  (input)->
    if (!!input) then input.charAt(0).toUpperCase() + input.substr(1).toLowerCase() else ''

archivist.filter 'prettytype', ->
  ref = {
    'ResponseDomainCode': 'Code',
    'ResponseDomainDatetime': 'Datetime',
    'ResponseDomainNumeric': 'Numeric',
    'ResponseDomainText': 'Text',
    'Category'          : 'Category',
    'Cateogie'          : 'Categorie',
    'CodeList'          : 'Code List',
    'QuestionGrid'      : 'Grid',
    'QuestionItem'      : 'Item'
  }
  (input)->
    if input.charAt(input.length - 1) == 's'
      plural = true
      input = input.slice 0, -1
    else
      plural = false

    if plural
      ref[input] + 's'
    else
      ref[input]