#= require_self

mapping = angular.module('archivist.mapping', [
  'ngRoute',
  'archivist.flash',
  'archivist.data_manager',
  'ngTagsInput'
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
      $routeParams
      DataManager
    )->
      $scope.instrument = DataManager.getInstrument(
        $routeParams.id,
        {
          constructs: true,
          questions: true
        },
        ->
          DataManager.resolveConstructs()
          DataManager.resolveQuestions()
      )

      $scope.tags = []

      $scope.fakeData = [{id:1,cod:123},
                        {id:2,cod:223},
                        {id:3,cod:323},
                        {id:4,cod:423},
                        {id:5,cod:523}]
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
      fixedTopic = (topic)->
        '<span class="a-topic">{{model.strand_topic.name}}</span>'

      nestedOptions = (scope)->
        console.log(scope)
        '<select class="form-control" data-ng-model="model.topic.id" style="width: 100%; max-width:600px;" convert-to-number>' +
        '<option value=""><em>Clear</em></option>' +
        '<option ' +
          'data-ng-repeat="topic in topics" ' +
          'data-ng-selected="topic.id == model.topic.id" ' +
          'data-a-topic-indent="{{topic.level}}" ' +
          'class="a-topic-level-{{topic.level}}" ' +
          'value="{{topic.id}}">{{topic.name}}</option>' +
        '</select>'

      {
        restrict: 'E'
        require: 'ngModel'
        scope:
          model: '=ngModel'

        link:
          post: ($scope, iElement, iAttrs)->
            $scope.topics = DataManager.getTopics {flattened: true}
            if $scope.model.topic? || (not $scope.model.strand_topic?)
              el = $compile(nestedOptions($scope))($scope)
            else
              el = $compile(fixedTopic($scope))($scope)
            iElement.replaceWith el

            $scope.$watch 'model.topic.id', (newVal, oldVal)->
              if newVal != oldVal
                bsLoadingOverlayService.start()
                DataManager.updateTopic($scope.model, newVal).then(null , (reason)->
                  $scope.model.topic.id = oldVal
                  Flash.add('danger', reason.data.message)
                ).finally(->
                  bsLoadingOverlayService.stop()
                )

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
