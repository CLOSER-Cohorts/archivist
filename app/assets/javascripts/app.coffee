archivist = angular.module('archivist', [
  'templates',
  'ngRoute',
  'archivist.flash',
  'archivist.instruments',
  'archivist.admin'
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
    $scope.isActive = (viewLocation) ->
      viewLocation == $location.path()
])

archivist.run(['$rootScope', 'flash',
  ($rootScope, Flash)->
    Array::unique = ->
      output = {}
      output[@[key]] = @[key] for key in [0...@length]
      value for key, value of output

    Array::select_resource_by_id = (ref_id)->
      output = (@[key] for key in [0...@length] when @[key].id == ref_id)[0]

    $rootScope.$on('$routeChangeSuccess', ->
      Flash.publish($rootScope)
    )
])