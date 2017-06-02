#= require_self

mapping = angular.module('archivist.mapping', [
  'ngRoute',
  'archivist.flash',
  'archivist.data_manager',
])

mapping.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/instruments/:id/map',
        templateUrl: 'partials/instruments/map.html'
        controller: 'MappingController'
      )
])

mapping.controller(
  'MappingController',
  [
    '$scope',
    '$routeParams',
    'DataManager',
    (
      $scope,
      $routeParams,
      DataManager
    )->
      $scope.instrument = DataManager.getInstrument(
        $routeParams.id,
        {
          constructs: true,
          questions: true,
          variables: true
        },
        ->
          DataManager.resolveConstructs()
          DataManager.resolveQuestions()
      )

      $scope.tags = {}
      $scope.variable={}

      $scope.addVariable = (item, question_id)->

        $scope.tags[question_id] = $scope.tags[question_id] || []
        $scope.tags[question_id] = pushVariable($scope.tags[question_id],item,question_id)

      $scope.deleteVariable = (question_id,idx)->
        $scope.tags[question_id].splice idx,1

      # $scope.detectKey = (event,question_id)->
      #   key = event.which || event.keyCode;
      #   if key == 44 || key == 13 || key ==32
      #     temp = {id:$scope.variable.added[question_id],cod:$scope.variable.added[question_id]}
      #     $scope.tags[question_id] = $scope.tags[question_id] || []
      #     $scope.tags[question_id] = pushVariable($scope.tags[question_id],temp,question_id) || []

      pushVariable = (array,item,question_id)->
        console.log array
        index = array.map((x) -> x.id).indexOf item.id
        if index == -1
          array.push item
        $scope.variable.added[question_id] = null
        array

      console.log 'Controller scope'
      console.log $scope

      $scope.split_mapping = (question, variable_id, x = null, y = null)->
        question.$split_mapping {
          variable_id: variable_id
          x: x
          y: y
        }
  ]
)

mapping.directive(
  'aTopics',
  [
    '$compile',
    'bsLoadingOverlayService',
    'DataManager',
    'Flash'
    (
      $compile,
      bsLoadingOverlayService,
      DataManager,
      Flash
    )->
      nestedOptions = (scope)->
        console.log(scope)
        '<select class="form-control" data-ng-model="model.topic.id" data-ng-init="model.topic.id = model.topic.id || model.ancestral_topic.id" style="width: 100%; ' +
        'max-width:600px;" convert-to-number data-ng-change="updateTopic()" data-ng-if="model.topic || !model.strand">' +
        '<option value=""><em>Clear</em></option>' +
        '<option ' +
          'data-ng-repeat="topic in topics" ' +
          'data-ng-selected="topic.id == model.topic.id" ' +
          'data-a-topic-indent="{{topic.level}}" ' +
          'class="a-topic-level-{{topic.level}}" ' +
          'value="{{topic.id}}">{{topic.name}}</option>' +
        '</select>' +
        '<span class="a-topic" data-ng-if="!model.topic && model.strand">{{model.strand.topic.name}}</span>'

      {
        restrict: 'E'
        require: 'ngModel'
        scope:
          model: '=ngModel'

        link:
          post: ($scope, iElement, iAttrs, ngModel)->
            init = ->
              console.log 'a topic init'
              $scope.model.orig_topic = $scope.model.topic
              $scope.topics = DataManager.getTopics {flattened: true}

              el = $compile(nestedOptions($scope))($scope)
              iElement.replaceWith el

            $scope.updateTopic = ->
              bsLoadingOverlayService.start()
              DataManager.updateTopic($scope.model, $scope.model.topic.id).then(->
                $scope.model.orig_topic = $scope.model.topic
              , (reason)->
                $scope.model.topic = $scope.model.orig_topic
                Flash.add('danger', reason.data.message)
              ).finally(->
                bsLoadingOverlayService.stop()
              )

            init()
      }
  ]
)

mapping.directive(
  'aTopicIndent',
  [
    ->
      {
        restrict: 'A'
        scope: {}
        link:
          post: ($scope, iElement, iAttrs, con)->
            $scope.$watch 'topic', ->
              iElement.text ("--".repeat(parseInt(iAttrs.aTopicIndent) - 1) + iElement.text())
      }
  ]
)
