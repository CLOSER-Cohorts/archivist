angular.module('archivist.build').controller(
  'BuildMenuController',
  [
    '$scope',
    '$routeParams',
    ($scope, $routeParams)->
      $scope.code_lists_url = '/instruments/' + $routeParams.id + '/build/codes'
      $scope.response_domains_url = '/instruments/' + $routeParams.id + '/build/response_domains'
      $scope.questions_url = '/instruments/' + $routeParams.id + '/build/questions'
      $scope.constructs_url = '/instruments/' + $routeParams.id + '/build/constructs'
  ]
)