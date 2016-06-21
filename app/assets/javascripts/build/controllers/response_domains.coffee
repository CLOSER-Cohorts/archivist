angular.module('archivist.build').controller(
  'BuildResponseDomainsController',
  [
    '$controller',
    '$scope',
    '$routeParams',
    '$location',
    '$filter',
    '$timeout',
    'Flash',
    'DataManager',
    'Map',
    'RealTimeListener',
    'RealTimeLocking',
    ($controller, $scope, $routeParams, $location, $filter, $timeout, Flash, DataManager, Map, RealTimeListener, RealTimeLocking)->

      $scope.load_sidebar = ->
        $scope.sidebar_objs = $filter('excludeRDC')($scope.instrument.ResponseDomains)

      $scope.title = 'Response Domains'
      $scope.extra_url_parameters = [
        'response_domains'
      ]
      $scope.instrument_options = {
        rds: true
      }

      $scope.delete = ->
        switch $routeParams.response_domain_type
          when 'response_domain_texts' then rd_type = 'ResponseDomainText'
          when 'response_domain_datetimes' then rd_type = 'ResponseDomainDatetime'
          when 'response_domain_numerics' then rd_type = 'ResponseDomainNumeric'
          else rd_type = false

        if rd_type?
          index = $scope.instrument.ResponseDomains.get_index_by_id_and_type(parseInt($routeParams.response_domain_id), rd_type)
          if index?
            $scope.instrument.ResponseDomains[index].$delete(
              {},
              ->
                $scope.instrument.ResponseDomains.splice index, 1
                $scope.load_sidebar()
                $timeout(
                  ->
                    if $scope.instrument.ResponseDomains.length > 0
                      $scope.change_panel $scope.instrument.ResponseDomains[0]
                    else
                      $scope.change_panel {type: rd_type, id: 'new'}
                ,0
                )
            )

      $scope.save = ->
        switch $routeParams.response_domain_type
          when 'response_domain_texts' then rd_type = 'ResponseDomainText'
          when 'response_domain_datetimes' then rd_type = 'ResponseDomainDatetime'
          when 'response_domain_numerics' then rd_type = 'ResponseDomainNumeric'
          when 'new'  then rd_type = 'new'
          else rd_type = false

        if rd_type
          if rd_type == 'new'
            res = Map.find DataManager, $scope.current.type
            arr = Map.find DataManager.Data, $scope.current.type
            console.log arr
            arr.push(
              new res.resource()
            )
            index = arr.length - 1
            for key of $scope.current
              arr[index][key] = $scope.current[key]
            arr[index]['instrument_id'] = $routeParams.id
          else
            arr = $scope.instrument.ResponseDomains
            index = arr.get_index_by_id_and_type parseInt($routeParams.response_domain_id), rd_type
            angular.copy $scope.current, arr[index]

          arr[index].save(
            {}
          ,(value, rh)->
            value['instrument_id'] = $scope.instrument.id
            Flash.add('success', 'Response Domain updated successfully!')
            DataManager.groupResponseDomains()
            $scope.reset()
            $scope.load_sidebar()
          ,->
            console.log("error")
          )

      $scope.reset = ->
        if $routeParams.response_domain_type? and $routeParams.response_domain_id?
          for rd in $scope.instrument.ResponseDomains
            if rd.type.camel_case_to_underscore() + 's' == $routeParams.response_domain_type and rd.id.toString() == $routeParams.response_domain_id

              $scope.current = angular.copy rd
              $scope.editMode = false
              if $scope.current?
                RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
              break
        if $routeParams.response_domain_type == 'new'
          $scope.editMode = true
          $scope.current = {}
        null

      $scope.new = ->
        $timeout(
          ->
            $scope.change_panel {type: null, id: 'new'}
        ,0
        )
        null

      $scope.after_instrument_loaded = ->
        $scope.load_sidebar()

      $controller(
        'BaseBuildController',
        {
          $scope: $scope,
          $routeParams: $routeParams,
          $location: $location,
          $timeout: $timeout,
          Flash: Flash,
          DataManager: DataManager,
          RealTimeListener: RealTimeListener,
          RealTimeLocking: RealTimeLocking
        }
      )
  ]
)