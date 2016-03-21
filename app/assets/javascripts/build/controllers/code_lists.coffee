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

      $scope.title = 'Code Lists'
      $scope.instrument_options = {
        rds: true
      }

      $scope.reset = () ->
        console.log "reset called"
        $scope.current = angular.copy $scope.code_lists.select_resource_by_id parseInt $routeParams.code_list_id
        $scope.editMode = false
        RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
        null


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

angular.module('archivist.build').controller(
  'BuildCodeListsController',
  [
    '$scope'
    '$routeParams',
    '$q',
    '$injector',
    '$location',
    'Flash',
    'Instruments',
    'CodeListsArchive',
    'CategoriesArchive',
    'CodeResolver',
    'RealTimeLocking',
    ($scope, $routeParams, $q, $injector, $location, Flash, Instruments, CodeLists, Categories, CodeResolver, RealTimeLocking)->

      $scope.instrument = Instruments.get {id: $routeParams.id}, ->
        $scope.page['title'] = $scope.instrument.prefix + ' | Code Lists'
      $scope.code_lists = CodeLists.query {instrument_id: $routeParams.id}
      $scope.categories = Categories.query {instrument_id: $routeParams.id}

      $q.all([
        $scope.instrument.$promise,
        $scope.code_lists.$promise,
        $scope.categories.$promise
      ]).then ()->


        get_count_from_used_by = (cl)->
          cl.count = cl.used_by.length
          cl
        $scope.sidebar_objs = (get_count_from_used_by obj for obj in $scope.code_lists)

        for code_list in $scope.code_lists
          CodeResolver.categories $scope, code_list

        if $routeParams.code_list_id?
          $scope.reset()
          $scope.$watch('current.newValue', (newVal, oldVal, scope)->
            console.log newVal, oldVal, scope
            if newVal != oldVal
              if newVal?
                scope.current.codes.push {id: null, value: newVal, category: null, order: null}
                $scope.current.newValue = null
          )

          $scope.breadcrumbs = [
            {label: 'Instruments', link: '/instruments', active: false},
            {label: $scope.instrument.prefix, link: '/instruments/' + $scope.instrument.id.toString(), active: false},
            {label: 'Build', link: '/instruments/' + $scope.instrument.id.toString() + '/build', active: false}
            {label: 'Code Lists', link: false, active: true}
          ]

      $scope.save = () ->
        angular.copy $scope.current, $scope.code_lists.select_resource_by_id(parseInt($routeParams.code_list_id))
        $scope.code_lists.select_resource_by_id(parseInt($routeParams.code_list_id)).$save(
          {}
        ,(value, rh)->
          value['instrument_id'] = $scope.instrument.id
          value['count'] = value.used_by.length
          Flash.add('success', 'Code list updated successfully!')
          $scope.reset()
        ,->
          console.log("error")
        )

      $scope.removeCode = (code) ->
        $scope.current.codes = (c for c in $scope.current.codes when c.$$hashKey != code.$$hashKey)

      $scope.reset = () ->
        console.log "reset called"
        $scope.current = angular.copy $scope.code_lists.select_resource_by_id parseInt $routeParams.code_list_id
        $scope.editMode = false
        RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
        null
  ]
)