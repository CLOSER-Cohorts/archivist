(function() {
  angular.module('archivist.build').controller('BuildMenuController', [
    '$scope', '$routeParams', 'DataManager', function($scope, $routeParams, DataManager) {
      $scope.code_lists_url = '/instruments/' + $routeParams.id + '/build/code_lists';
      $scope.response_domains_url = '/instruments/' + $routeParams.id + '/build/response_domains';
      $scope.questions_url = '/instruments/' + $routeParams.id + '/build/questions';
      $scope.constructs_url = '/instruments/' + $routeParams.id + '/build/constructs';
      $scope.summary_url = function(arg) {
        return '/instruments/' + $routeParams.id + '/summary/' + arg;
      };
      return $scope.instrument = DataManager.getInstrumentStats($routeParams.id, function() {
        $scope.stats = $scope.instrument.stats;
        return $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/instruments',
            active: false
          }, {
            label: $scope.instrument.prefix,
            link: '/instruments/' + $routeParams.id,
            active: false
          }, {
            label: 'Build',
            link: false,
            active: true
          }
        ];
      });
    }
  ]);

}).call(this);
