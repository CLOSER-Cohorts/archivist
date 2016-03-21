angular.module('archivist.build').controller(
  'BuildQuestionsController',
  [
    '$scope',
    '$routeParams',
    '$location',
    '$injector',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    (
      $scope,
      $routeParams,
      $location,
      $injector,
      Flash,
      DataManager,
      RealTimeListener,
      RealTimeLocking
    ) ->

      $injector.invoke(
        Toolbox,
        this,
        {
          $scope: $scope,
          DataManager: DataManager,
          title: "Questions",
          extra_url_parameters: [
            'questions'
          ],
          instrument_options: {
            questions: true,
            rds: true
          }
        }
      )

      $scope.instrument = DataManager.getInstrument($routeParams.id,{questions: true, rds: true}, ()->
        $scope.page['title'] = $scope.instrument.prefix + ' | Questions'
        $scope.sidebar_objs =  $scope.instrument.Questions.Items.concat $scope.instrument.Questions.Grids
        if $routeParams.question_id?
          $scope.reset()

          $scope.breadcrumbs = [
            {label: 'Instruments', link: '/instruments', active: false},
            {label: $scope.instrument.prefix, link: '/instruments/' + $scope.instrument.id.toString(), active: false},
            {label: 'Build', link: '/instruments/' + $scope.instrument.id.toString() + '/build', active: false}
            {label: 'Questions', link: false, active: true}
          ]
      )

      $scope.save = () ->
        if $routeParams.question_type == 'question_items'
          angular.copy $scope.current, $scope.instrument.Questions.Items.select_resource_by_id(parseInt($routeParams.question_id))
          $scope.instrument.Questions.Items.select_resource_by_id(parseInt($routeParams.question_id)).$save(
            {}
          ,(value, rh)->
            value['instrument_id'] = $scope.instrument.id
            Flash.add('success', 'Question updated successfully!')
            $scope.reset()
          ,->
            console.log("error")
          )


      $scope.reset = () ->
        console.log "reset called"
        if $routeParams.question_type == 'question_items'
          $scope.current = angular.copy $scope.instrument.Questions.Items.select_resource_by_id parseInt $routeParams.question_id
          $scope.title = 'Question Item'
        else
          $scope.current = angular.copy $scope.instrument.Questions.Grids.select_resource_by_id parseInt $routeParams.question_id
          $scope.title = 'Question Grid'
        $scope.editMode = false
        RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
        null

  ]
)