archivist = angular.module('archivist', [
  'templates',
  'ngRoute',
  'archivist.instruments',
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

archivist.controller('RootController', [ '$scope', '$location',
  ($scope, $location)->
    $scope.softwareName = 'Archivist'
    $scope.isActive = (viewLocation) ->
      viewLocation == $location.path()
])

archivist.run(
  ->
    Array::unique = ->
      output = {}
      output[@[key]] = @[key] for key in [0...@length]
      value for key, value of output
)