angular.module('archivist.build').controller(
  'BuildCodeListsController',
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

      $scope.save =  ->
        angular.copy $scope.current, $scope.instrument.CodeLists.select_resource_by_id(parseInt($routeParams.code_list_id))
        $scope.instrument.CodeLists.select_resource_by_id(parseInt($routeParams.code_list_id)).$save(
          {}
        ,(value, rh)->
          value['instrument_id'] = $scope.instrument.id
          Flash.add('success', 'Code list updated successfully!')
          $scope.reset()
        ,->
          console.log("error")
        )

      $scope.title = 'Code Lists'
      $scope.instrument_options = {
        codes: true
      }

      $scope.reset = () ->
        console.log "reset called"
        if not isNaN($routeParams.code_list_id)
          $scope.current = angular.copy $scope.instrument.CodeLists.select_resource_by_id parseInt $routeParams.code_list_id
          $scope.editMode = false
          if $scope.current?
            RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
        if $routeParams.code_list_id == 'new'
          $scope.editMode = true

      $scope.new = ->
        $scope.change_panel {type: 'CodeList', id: 'new'}

      $scope.after_instrument_loaded = ->
        get_count_from_used_by = (cl)->
          cl.count = cl.used_by.length
          cl
        $scope.sidebar_objs = (get_count_from_used_by obj for obj in $scope.instrument.CodeLists)
        if !DataManager.CodeResolver?
          DataManager.resolveCodes()

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