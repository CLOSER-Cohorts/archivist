angular.module('archivist.build').controller(
  'BuildCodeListsController',
  [
    '$controller',
    '$scope',
    '$routeParams',
    '$location',
    '$filter',
    '$timeout'
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    ($controller, $scope, $routeParams, $location, $filter, $timeout, Flash, DataManager, RealTimeListener, RealTimeLocking)->

      console.log 'called code_list controller'

      $scope.load_sidebar = ->
        get_count_from_used_by = (cl)->
          cl.count = cl.used_by.length
          cl
        $scope.sidebar_objs = (get_count_from_used_by obj for obj in $scope.instrument.CodeLists)

      $scope.delete = ->
        index = $scope.instrument.CodeLists.get_index_by_id parseInt($routeParams.code_list_id)
        if index?
          $scope.instrument.CodeLists[index].$delete(
            {},
            ->
              $scope.instrument.CodeLists.splice index, 1
              $scope.load_sidebar()
              $timeout(
                ->
                  if $scope.instrument.CodeLists.length > 0
                    $scope.change_panel $scope.instrument.CodeLists[0]
                  else
                    $scope.change_panel {type: 'CodeList', id: 'new'}
                ,0
              )
          )

      $scope.save =  ->
        console.log $scope.current
        if $routeParams.code_list_id == 'new'
          $scope.instrument.CodeLists.push $scope.current
          index = $scope.instrument.CodeLists.length - 1
          $scope.instrument.CodeLists[index].instrument_id = $routeParams.id
        else
          angular.copy $scope.current, $scope.instrument.CodeLists.select_resource_by_id(parseInt($routeParams.code_list_id))
          index = $scope.instrument.CodeLists.get_index_by_id parseInt($routeParams.code_list_id)
        $scope.instrument.CodeLists[index].save(
          {}
        ,(value, rh)->
          value['instrument_id'] = $scope.instrument.id
          Flash.add('success', 'Code list updated successfully!')
          $scope.reset()
          $scope.load_sidebar()
        ,->
          console.log("error")
        )

        DataManager.Data.ResponseDomains[$routeParams.id] = null

      $scope.title = 'Code Lists'
      $scope.instrument_options = {
        codes: true
      }

      $scope.reset = () ->
        console.log "reset called"
        if !DataManager.CodeResolver?
          DataManager.resolveCodes()
        if not isNaN($routeParams.code_list_id)
          $scope.current = angular.copy $scope.instrument.CodeLists.select_resource_by_id parseInt $routeParams.code_list_id
          $scope.editMode = false
          if $scope.current?
            RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
        if $routeParams.code_list_id == 'new'
          $scope.editMode = true
          $scope.current = new DataManager.Codes.CodeLists.resource({codes: []});

      $scope.new = ->
        $scope.change_panel {type: 'CodeList', id: 'new'}

      $scope.removeCode = (code) ->
        $scope.current.codes = (c for c in $scope.current.codes when c.$$hashKey != code.$$hashKey)

      $scope.after_instrument_loaded = ->
        $scope.categories = DataManager.Data.Codes.Categories
        $scope.load_sidebar()

        $scope.$watch('current.newValue', (newVal, oldVal, scope)->
          console.log newVal, oldVal, scope
          if newVal != oldVal
            if newVal?
              scope.current.codes.push {id: null, value: newVal, category: null, order: $scope.current.codes.length}
              $scope.current.newValue = null
              #TODO: Remove DOM code from controllers
              $timeout(
                ->
                  jQuery('.code-value').last().focus()
                ,0
              )
        )

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