angular.module('archivist.build').controller(
  'BuildResponseDomainsController',
  [
    '$controller',
    '$scope',
    '$routeParams',
    '$location',
    '$filter',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    ($controller, $scope, $routeParams, $location, $filter, Flash, DataManager, RealTimeListener, RealTimeLocking)->

      $scope.title = 'Response Domains'
      $scope.extra_url_parameters = [
        'response_domains'
      ]
      $scope.instrument_options = {
        rds: true
      }

      $scope.reset = ->
        if $routeParams.response_domain_type? and $routeParams.response_domain_id?
          for rd in $scope.instrument.ResponseDomains
            if rd.type.camel_case_to_underscore() + 's' == $routeParams.response_domain_type and rd.id.toString() == $routeParams.response_domain_id

              $scope.current = angular.copy rd
              $scope.editMode = false
              break

        null

      $scope.after_instrument_loaded = ->
        $scope.sidebar_objs = $filter('excludeRDC')($scope.instrument.ResponseDomains)

      $controller(
        'BaseBuildController',
        {
          $scope: $scope,
          $routeParams: $routeParams,
          $location: $location,
          Flash: Flash,
          DataManager: DataManager,
          RealTimeListener: RealTimeListener,
          RealTimeLocking: RealTimeLocking
        }
      )
  ]
)