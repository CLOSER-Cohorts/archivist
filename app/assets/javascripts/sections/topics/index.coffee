#= require_self

topics = angular.module('archivist.topics', [
  'ngRoute',
  'archivist.data_manager'
])

topics.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
    .when('/topics',
      templateUrl: 'partials/topics/index.html'
      controller: 'TopicsIndexController'
    )
])

topics.controller(
  'TopicsIndexController',
  [
    '$scope',
    '$routeParams',
    'DataManager',
    (
      $scope,
      $routeParams
      DataManager
    )->
      $scope.data = DataManager.getTopics nested: true
      $scope.treeOptions =
        dirSelectable: false

      console.log $scope
  ]
)