angular.module('archivist.build').controller(
  'BuildConstructsController',
  [
    '$controller',
    '$scope',
    '$routeParams',
    '$location',
    '$filter',
    '$http',
    '$timeout',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    ($controller, $scope, $routeParams, $location, $filter, $http, $timeout, Flash, DataManager, RealTimeListener, RealTimeLocking)->
      console.time 'end to end'
      $scope.title = 'Constructs'
      $scope.details_bar = true
      $scope.hide_edit_buttons = true
      $scope.extra_url_parameters = [
        'constructs'
      ]
      $scope.instrument_options = {
        constructs: true
        questions: true
        rus: true
      }
      $scope.index = {}

      $scope.details_path = ->
        'partials/build/details/' + $routeParams.construct_type + '.html'

      $scope.setIndex = (parent_id, parent_type, branch = null)->
        if parent_id?
          $scope.index.parent_id = parent_id
          $scope.index.parent_type = parent_type
        else
          $scope.index.parent_id = $scope.instrument.topsequence.id
          $scope.index.parent_type = 'sequence'
        $scope.index.branch = branch

      $scope.$on '$routeUpdate', (scope, next, current) ->
        $scope.reset()

      $scope.change_panel = (obj)->
        $location.search {construct_type: obj.type, construct_id: obj.id}
        $scope.editMode = obj.type? and obj.id?

      $scope.sortableOptions = {
        placeholder: 'a-construct',
        connectWith: '.a-construct-container',
        stop: (e, ui)->
          updates = []
          positionUpdater = (parent)->
            child_dimensions = ['children', 'fchildren']
            for dimension, index in child_dimensions
              if parent[dimension]?
                for child_key of parent[dimension]
                  if parent[dimension].hasOwnProperty child_key
                    console.log parent[dimension][child_key].branch
                    if parent[dimension][child_key].position != (parseInt child_key) + 1 or parent[dimension][child_key].parent != parent.id or parent[dimension][child_key].branch != index
                      updates.push {
                        id: parent[dimension][child_key].id,
                        type: parent[dimension][child_key].type,
                        position: (parseInt child_key) + 1,
                        parent: {id: parent.id, type: parent.type},
                        branch: index
                      }
                      parent[dimension][child_key].position = updates[updates.length-1]['position']
                      parent[dimension][child_key].parent = updates[updates.length-1]['parent']
                    positionUpdater parent[dimension][child_key]

          positionUpdater $scope.instrument.topsequence
          $http.post '/instruments/' + $scope.instrument.id.toString() + '/reorder_ccs.json', updates: updates
      }

      $scope.delete = ->
        arr = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's']
        index = arr.get_index_by_id parseInt($routeParams.construct_id)
        if index?
          arr[index].$delete(
            {},
            ->
              arr.splice index, 1
              $timeout(
                ->
                  $scope.change_panel {type: null, id: null}
              ,0
              )
          )

      $scope.save =  ->
        console.log $scope.current
        arr = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's']
        console.log arr
        if $routeParams.construct_id == 'new'
          arr.push $scope.current
          index = arr.length - 1
          arr[index].instrument_id = $routeParams.id
        else
          angular.copy $scope.current, arr.select_resource_by_id(parseInt($routeParams.construct_id))
          index = arr.get_index_by_id parseInt($routeParams.construct_id)
        arr[index].save(
          {}
        ,(value, rh)->
          console.log "save returned"
          value['instrument_id'] = $scope.instrument.id
          value['type'] = $routeParams.construct_type
          Flash.add('success', 'Construct updated successfully!')

          if $routeParams.construct_id == 'new'
            parent = DataManager.Data.Instrument.Constructs[$scope.index.parent_type.capitalizeFirstLetter() + 's'].select_resource_by_id($scope.index.parent_id)
            if $scope.index.branch == 0 or $scope.index.branch == null
              parent.children.push arr[index]
            else
              parent.fchildren.push arr[index]

            $scope.change_panel arr[index]

          $scope.change_panel {type: null, id: null}
          $scope.reset()
        ,->
          console.log("error")
        )

      $scope.reset = ->
        console.time 'reset'
        console.log $routeParams
        if $routeParams.construct_type? and !isNaN(parseInt($routeParams.construct_id))
          for cc in $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's']
            if cc.type.pascal_case_to_underscore() == $routeParams.construct_type and cc.id.toString() == $routeParams.construct_id.toString()

              $scope.current = angular.copy cc
              break

        console.timeEnd 'reset'
        null

      $scope.build_ru_options = ->
        $scope.details.ru_options = []
        for ru in $scope.instrument.ResponseUnits
          $scope.details.ru_options.push {value: ru.id, label: ru.label}

      $scope.after_instrument_loaded = ->
        console.time 'after instrument'
        constructSorter = (a, b)->
          a.position > b.position
        if !$scope.instrument.topsequence.resolved
          DataManager.resolve().then ->
            $scope.instrument = DataManager.Data.Instrument
            sortChildren = (parent)->
              if parent.children?
                parent.children.sort constructSorter
                for child in parent.children
                  sortChildren child
                if parent.fchildren?
                  parent.fchildren.sort constructSorter
                  for child in parent.fchildren
                    sortChildren child
            sortChildren $scope.instrument.topsequence

        $scope.details = {}
        $scope.details.item_options = DataManager.getQuestionItemIDs()
        $scope.details.grid_options = DataManager.getQuestionGridIDs()

        $scope.build_ru_options()

        console.timeEnd 'after instrument'
        console.timeEnd 'end to end'

      $scope.save_ru = (new_interviewee)->
        DataManager.Data.ResponseUnits.push new DataManager.ResponseUnits.resource({
          label: new_interviewee.label,
          instrument_id: $routeParams.id
        })
        DataManager.Data.ResponseUnits[DataManager.Data.ResponseUnits.length - 1].save(
          {}
        ,(value, rh)->
          value['instrument_id'] = $scope.instrument.id
          $scope.build_ru_options()
        )

      $scope.new = (cc_type)->
        if cc_type == 'question'
          resource = DataManager.Constructs.Questions.cc.resource
        else
          resource = DataManager.Constructs[cc_type.capitalizeFirstLetter() + 's'].resource
        $scope.current = new resource({
          type: cc_type,
          parent: {id: $scope.index.parent_id, type: $scope.index.parent_type}
          branch: $scope.index.branch
        })
        $location.search {construct_type: cc_type, construct_id: 'new'}

        console.log $scope.current
        $scope.reset()
        $scope.editMode = true

      console.time 'load base'
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
      console.timeEnd 'load base'
      console.log $scope
  ]
)

angular.module('archivist.build').controller(
  'BuildConstructsFirstBranchController',
  [
    '$scope',
    ($scope)->
      $scope.branch = if $scope.obj.type == 'condition' then  0 else null
  ]
)

angular.module('archivist.build').controller(
  'BuildConstructsSecondBranchController',
  [
    '$scope',
    ($scope)->
      $scope.branch = 1
  ]
)