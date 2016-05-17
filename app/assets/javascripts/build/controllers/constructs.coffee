angular.module('archivist.build').controller(
  'BuildConstructsController',
  [
    '$controller',
    '$scope',
    '$routeParams',
    '$location',
    '$filter',
    '$http',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    ($controller, $scope, $routeParams, $location, $filter, $http, Flash, DataManager, RealTimeListener, RealTimeLocking)->
      console.time 'end to end'
      $scope.title = 'Constructs'
      $scope.overview = true
      $scope.hide_edit_buttons = true
      $scope.extra_url_parameters = [
        'constructs'
      ]
      $scope.instrument_options = {
        constructs: true
        questions: true
      }
      $scope.index = {}

      $scope.details_path = ->
        'partials/build/details/' + $routeParams.construct_type + '.html'

      $scope.setIndex = (parent, position)->
        $scope.index.parent = parent
        $scope.index.position = position

      $scope.$on '$routeUpdate', (scope, next, current) ->
        $scope.reset()

      $scope.change_panel = (obj)->
        $location.search {construct_type: obj.type, construct_id: obj.id}
        $scope.editMode = true

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

      $scope.save =  ->
        console.log $scope.current
        arr = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's']
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
          value['instrument_id'] = $scope.instrument.id
          Flash.add('success', 'Construct updated successfully!')
          $scope.reset()
        ,->
          console.log("error")
        )

      $scope.reset = ->
        console.time 'reset'
        console.log $routeParams
        if $routeParams.construct_type? and !isNaN(parseInt($routeParams.construct_id))
          for cc in $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's']
            if cc.type.camel_case_to_underscore() == $routeParams.construct_type and cc.id.toString() == $routeParams.construct_id.toString()

              $scope.current = angular.copy cc
              break

        if $scope.current?
          if $scope.current.type == 'question'
            $scope.details = {}
            $scope.details.item_options = DataManager.getQuestionItemIDs()
            $scope.details.grid_options = DataManager.getQuestionGridIDs()

            DataManager.getResponseUnits $scope.instrument.id, false, ()->
              $scope.details.ru_options = []
              for ru in DataManager.Data.ResponseUnits[$scope.instrument.id]
                $scope.details.ru_options.push {value: ru.id, label: ru.label}

        console.timeEnd 'reset'
        null

      $scope.after_instrument_loaded = ->
        console.time 'after instrument'
        constructSorter = (a, b)->
          a.position > b.position
        if !$scope.instrument.topsequence.resolved
          DataManager.resolveConstructs()
          DataManager.resolveQuestions()
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

        console.timeEnd 'after instrument'
        console.timeEnd 'end to end'

      $scope.new = (cc_type)->
        if cc_type == 'question'
          resource = DataManager.Constructs.Questions.cc.resource
        else
          resource = DataManager.Constructs[cc_type.capitalizeFirstLetter() + 's'].resource
        $scope.current = new resource({
          type: cc_type,
          position: $scope.index.position,
          parent: $scope.index.parent
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