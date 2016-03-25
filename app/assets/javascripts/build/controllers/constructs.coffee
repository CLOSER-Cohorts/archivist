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

      $scope.$on '$routeUpdate', (scope, next, current) ->
        $scope.reset()

      $scope.change_panel = (obj)->
        $location.search {construct_type: obj.type, construct_id: obj.id}

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

      $scope.reset = ->
        console.time 'reset'
        console.log $routeParams
        if $routeParams.construct_type? and $routeParams.construct_id?
          for cc in $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's']
            if cc.type.camel_case_to_underscore() == $routeParams.construct_type and cc.id.toString() == $routeParams.construct_id.toString()

              $scope.current = angular.copy cc
              $scope.editMode = false
              break

        if $scope.current?
          $scope.details = {fields: []}
          for key of $scope.current
            if ['label', 'literal'].indexOf(key) >= 0
              $scope.details.fields.splice 0, 0, {label: key.capitalizeFirstLetter(), model: $scope.current[key]}

          if $scope.current.type == 'question'
            $scope.details.fields.push {
              label: 'Type',
              model: $scope.current.question_type,
              options:[
                {value: 'QuestionItem', label: 'Item'},
                {value: 'QuestionGrid', label: 'Grid'}
              ]
            }
            $scope.details.fields.push {
              label: 'Question',
              model: $scope.current.question_id,
              options: if $scope.current.question_type == 'QuestionItem' then DataManager.getQuestionItemIDs() else DataManager.getQuestionGridIDs()
            }
            DataManager.getResponseUnits $scope.instrument.id, false, ()->
              options = []
              for ru in DataManager.Data.ResponseUnits[$scope.instrument.id]
                options.push {value: ru.id, label: ru.label}
              $scope.details.fields.push {
                label: 'Interviewee',
                model: $scope.current.response_unit_id,
                options: options
              }

        console.timeEnd 'reset'
        null

      $scope.after_instrument_loaded = ->
        console.time 'after instrument'
        constructSorter = (a, b)->
          a.position > b.position
        if !DataManager.ConstructResolver?
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

      $scope.new = ->
        $location.search {construct_type: null, construct_id: null}
        $scope.current = {}
        $scope.details = {fields: []}
        $scope.details.fields.push {
          label: 'Construct',
          model: $scope.current.construct_type,
          options:[
            {value: 'condition', label: 'Condition'},
            {value: 'loop', label: 'Loop'},
            {value: 'quesiton', label: 'Question'},
            {value: 'sequence', label: 'Sequence'},
            {value: 'statement', label: 'Statement'}
          ]
        }

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