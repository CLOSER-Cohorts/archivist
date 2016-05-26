angular.module('archivist.build').controller(
  'BuildQuestionsController',
  [
    '$controller',
    '$scope',
    '$routeParams',
    '$location',
    '$timeout',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    (
      $controller,
      $scope,
      $routeParams,
      $location,
      $timeout
      Flash,
      DataManager,
      RealTimeListener,
      RealTimeLocking
    ) ->

      $scope.load_sidebar = ->
        $scope.sidebar_objs = $scope.instrument.Questions.Items.concat $scope.instrument.Questions.Grids

      $scope.add_rd = (rd)->
        if !$scope.current.rds?
          $scope.current.rds = []
        $scope.current.rds.push rd

      $scope.delete = ->
        if $routeParams.question_type == 'question_items'
          qtype = 'Items'
        else
          qtype = 'Grids'

        if qtype?
          index = $scope.instrument.Questions[qtype].get_index_by_id parseInt($routeParams.question_id)
          if index?
            $scope.instrument.Questions[qtype][index].$delete(
              {},
              ->
                $scope.instrument.Questions[qtype].splice index, 1
                $scope.load_sidebar()
                $timeout(
                  ->
                    if $scope.instrument.Questions[qtype].length > 0
                      $scope.change_panel $scope.instrument.Questions[qtype][0]
                    else
                      $scope.change_panel {type: $routeParams.question_type, id: 'new'}
                ,0
                )
            )

      $scope.save =  ->
        if $routeParams.question_type == 'question_items'
          qtype = 'Items'
        else
          qtype = 'Grids'

        if qtype?
          if $routeParams.question_id == 'new'
            $scope.instrument.Questions[qtype].push $scope.current
            index = $scope.instrument.Questions[qtype].length - 1
            $scope.instrument.Questions[qtype][index].instrument_id = $routeParams.id
          else
            angular.copy $scope.current, $scope.instrument.Questions[qtype].select_resource_by_id(parseInt($routeParams.question_id))
            index = $scope.instrument.Questions[qtype].get_index_by_id parseInt($routeParams.question_id)

          $scope.instrument.Questions[qtype][index].save(
              {}
            ,(value, rh)->
              value['instrument_id'] = $scope.instrument.id
              Flash.add('success', 'Question updated successfully!')
              $scope.reset()
              $scope.load_sidebar()
            ,->
              console.log("error")
            )

      $scope.title = 'Questions'
      $scope.extra_url_parameters = [
        'questions'
      ]
      $scope.instrument_options = {
        questions: true,
        rds: true,
        codes: true
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



          if $routeParams.question_id == 'new'
            $scope.editMode = true
            if $routeParams.question_type = 'question_items'
              $scope.current = new DataManager.Constructs.Questions.item.resource({});
            else if $routeParams.question_type = 'question_grids'
              $scope.current = new DataManager.Constructs.Questions.grid.resource({});

        null

      $scope.new = (type = false)->
        if type == false
          jQuery('#new-question').modal('show')
        else
          $timeout(
            ->
              $scope.change_panel {type: type, id: 'new'}
            ,0
          )
        null

      $scope.after_instrument_loaded = ->
        console.log 'here'
        $scope.sidebar_objs = $scope.instrument.Questions.Items.concat $scope.instrument.Questions.Grids
        DataManager.resolveCodes()
        console.log $scope.sidebar_objs

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