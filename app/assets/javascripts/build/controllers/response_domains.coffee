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

      $scope.save = ->
        switch $routeParams.response_domain_type
          when 'response_domain_texts' then rd_type = 'ResponseDomainText'
          when 'response_domain_datetimes' then rd_type = 'ResponseDomainDatetime'
          when 'response_domain_numerics' then rd_type = 'ResponseDomainNumeric'
          else rd_type = false

        if rd_type
          console.log $scope.current
          angular.copy $scope.current, $scope.instrument.ResponseDomains.select_resource_by_id_and_type(parseInt($routeParams.response_domain_id, rd_type))
          console.log $scope.instrument.ResponseDomains.select_resource_by_id_and_type(parseInt($routeParams.response_domain_id), rd_type)
          $scope.instrument.ResponseDomains.select_resource_by_id_and_type(parseInt($routeParams.response_domain_id), rd_type).$save(
            {}
          ,(value, rh)->
            value['instrument_id'] = $scope.instrument.id
            Flash.add('success', 'Response Domain updated successfully!')
            $scope.reset()
          ,->
            console.log("error")
          )

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