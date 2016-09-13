angular.module('archivist.build').controller(
  'BuildMenuController',
  [
    '$scope',
    '$routeParams',
    'DataManager'
    ($scope, $routeParams, DataManager)->
      $scope.code_lists_url = '/instruments/' + $routeParams.id + '/build/code_lists'
      $scope.response_domains_url = '/instruments/' + $routeParams.id + '/build/response_domains'
      $scope.questions_url = '/instruments/' + $routeParams.id + '/build/questions'
      $scope.constructs_url = '/instruments/' + $routeParams.id + '/build/constructs'

      $scope.summary_url = (arg)->
        '/instruments/' + $routeParams.id + '/summary/' + arg

      $scope.stats = DataManager.getInstrumentStats($routeParams.id)
  ]
)