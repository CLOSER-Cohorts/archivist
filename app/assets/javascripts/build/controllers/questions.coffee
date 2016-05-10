angular.module('archivist.build').controller(
  'BuildQuestionsController',
  [
    '$controller',
    '$scope',
    '$routeParams',
    '$location',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    (
      $controller,
      $scope,
      $routeParams,
      $location,
      Flash,
      DataManager,
      RealTimeListener,
      RealTimeLocking
    ) ->

      $scope.save =  ->
        if $routeParams.question_type == 'question_items'
          qtype = 'Items'
        else
          qtype = 'Grids'

        if qtype?
          angular.copy $scope.current, $scope.instrument.Questions[qtype].select_resource_by_id(parseInt($routeParams.question_id))
          $scope.instrument.Questions[qtype].select_resource_by_id(parseInt($routeParams.question_id)).$save(
            {}
          ,(value, rh)->
            value['instrument_id'] = $scope.instrument.id
            Flash.add('success', 'Question updated successfully!')
            $scope.reset()
          ,->
            console.log("error")
          )

      $scope.title = 'Questions'
      $scope.extra_url_parameters = [
        'questions'
      ]
      $scope.instrument_options = {
        questions: true,
        rds: true
      }

      $scope.reset = () ->
        console.log "reset called"
        if $routeParams.question_type?
          if $routeParams.question_type == 'question_items'
            $scope.current = angular.copy $scope.instrument.Questions.Items.select_resource_by_id parseInt $routeParams.question_id
            $scope.title = 'Question Item'
          else
            $scope.current = angular.copy $scope.instrument.Questions.Grids.select_resource_by_id parseInt $routeParams.question_id
            $scope.title = 'Question Grid'
          $scope.editMode = false
          if $scope.current?
            RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})

        null

      $scope.new = ->
        $scope.change_panel {type: null, id: 'new'}

      $scope.after_instrument_loaded = ->
        console.log 'here'
        $scope.sidebar_objs = $scope.instrument.Questions.Items.concat $scope.instrument.Questions.Grids
        console.log $scope.sidebar_objs

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