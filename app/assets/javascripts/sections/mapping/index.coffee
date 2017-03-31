#= require_self

mapping = angular.module('archivist.mapping', [
  'ngRoute',
  'archivist.flash',
  'archivist.data_manager'
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
  ]
)

mapping.directive(
  'aTopics',
  [
    '$compile',
    'DataManager'
    (
      $compile,
      DataManager
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
              console.log('Topic change detected')
              console.log(newVal)
              if newVal != oldVal
                DataManager.updateTopic($scope.model, newVal)

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