mapping = angular.module('archivist.instruments.mapping', [
  'ngRoute',
  'archivist.flash',
  'archivist.data_manager'
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
      nestedOptions = (scope)->
        '<select class="form-control" data-ng-model="model.topic">' +
        '<option value="">None</option>' +
        '<option ' +
          'data-ng-repeat="topic in topics" ' +
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
            el = $compile(nestedOptions($scope))($scope)
            iElement.replaceWith el

            $scope.$watch 'model.topic', (newVal, oldVal)->
              if newVal != oldVal
                $scope.model.$save()

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