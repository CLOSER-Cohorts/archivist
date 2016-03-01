archivist = angular.module('archivist', [
  'templates',
  'ngRoute',
  'ui.sortable',
  'archivist.flash',
  'archivist.instruments',
  'archivist.build',
  'archivist.admin',
  'archivist.realtime'
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

archivist.controller('RootController', [ '$scope', '$location', 'Flash'
  ($scope, $location, Flash)->
    $scope.softwareName = 'Archivist'
    $scope.page['title'] = 'Home'
    $scope.isActive = (viewLocation) ->
      viewLocation == $location.path()
])

archivist.directive 'notices', ->
  {
    templateURL: 'partials/notices.html'
  }

archivist.run(['$rootScope', 'Flash', 'RealTimeConnection'
  ($rootScope, Flash, RealTimeConnection)->
    Array::unique = ->
      output = {}
      output[@[key]] = @[key] for key in [0...@length]
      value for key, value of output

    Array::select_resource_by_id = (ref_id)->
      output = (@[key] for key in [0...@length] when @[key].id == ref_id)[0]

    String::replaceAll = (search, replacement) ->
      target = this
      target.replace(new RegExp(search, 'g'), replacement)

    String::camel_case_to_underscore = ->
      target = this
      target.replace(/([A-Z])/g, (x,y) -> "_"+y.toLowerCase()).replace /^_/, ''

    String::capitalizeFirstLetter = ->
      target = this
      target.charAt(0).toUpperCase() + target.slice(1)

    $rootScope.$on('$routeChangeSuccess', ->
      Flash.publish($rootScope)
    )
    Flash.publish($rootScope)

    $rootScope.page = {title: 'Home'}
])