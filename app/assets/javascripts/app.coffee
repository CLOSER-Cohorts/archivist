archivist = angular.module('archivist', [
  'templates',
  'ngRoute',
  'ui.sortable',
  'archivist.flash',
  'archivist.instruments',
  'archivist.build',
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

    String::replaceAll = (search, replacement) ->
      target = this
      target.replace(new RegExp(search, 'g'), replacement)

    String::camel_case_to_underscore = ->
      target = this
      target.replace(/([A-Z])/g, (x,y) -> "_"+y.toLowerCase()).replace /^_/, ''

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