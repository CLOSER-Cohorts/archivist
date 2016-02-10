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

archivist.controller('RootController', [ '$scope', '$location', 'flash'
  ($scope, $location, Flash)->
    $scope.softwareName = 'Archivist'
    $scope.page['title'] = 'Home'
    $scope.isActive = (viewLocation) ->
      viewLocation == $location.path()
])

archivist.run(['$rootScope', 'flash', 'RealTimeConnection'
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

    $rootScope.$on('$routeChangeSuccess', ->
      Flash.publish($rootScope)
    )

    $rootScope.page = {title: 'Home'}
])