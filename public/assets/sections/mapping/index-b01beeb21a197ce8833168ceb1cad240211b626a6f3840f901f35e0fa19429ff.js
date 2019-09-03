(function() {
  var mapping;

  mapping = angular.module('archivist.mapping', ['ngRoute', 'archivist.flash', 'archivist.data_manager']);

  mapping.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/instruments/:id/map', {
        templateUrl: 'partials/instruments/map.html',
        controller: 'MappingController'
      });
    }
  ]);

  mapping.controller('MappingController', [
    '$scope', '$routeParams', 'DataManager', function($scope, $routeParams, DataManager) {
      var pushVariable;
      $scope.instrument = DataManager.getInstrument($routeParams.id, {
        constructs: true,
        questions: true,
        variables: true
      }, function() {
        DataManager.resolveConstructs();
        return DataManager.resolveQuestions();
      });
      $scope.tags = {};
      $scope.variable = {};
      $scope.addVariable = function(item, question_id) {
        $scope.tags[question_id] = $scope.tags[question_id] || [];
        return $scope.tags[question_id] = pushVariable($scope.tags[question_id], item, question_id);
      };
      $scope.deleteVariable = function(question_id, idx) {
        return $scope.tags[question_id].splice(idx, 1);
      };
      $scope.detectKey = function(event, question, x, y) {
        var variables;
        if (x == null) {
          x = null;
        }
        if (y == null) {
          y = null;
        }
        if (event.keyCode === 13) {
          variables = event.target.value.split(',');
          DataManager.addVariables(question, variables).then(function() {
            return $scope.model.orig_topic = $scope.model.topic;
          }, function(reason) {
            return question.errors = reason.data.message;
          });
        }
        return console.log(question);
      };
      pushVariable = function(array, item, question_id) {
        var index;
        console.log(array);
        index = array.map(function(x) {
          return x.id;
        }).indexOf(item.id);
        if (index === -1) {
          array.push(item);
        }
        $scope.variable.added[question_id] = null;
        return array;
      };
      console.log('Controller scope');
      console.log($scope);
      return $scope.split_mapping = function(question, variable_id, x, y) {
        if (x == null) {
          x = null;
        }
        if (y == null) {
          y = null;
        }
        return question.$split_mapping({
          variable_id: variable_id,
          x: x,
          y: y
        });
      };
    }
  ]);

  mapping.directive('aTopics', [
    '$compile', 'bsLoadingOverlayService', 'DataManager', 'Flash', function($compile, bsLoadingOverlayService, DataManager, Flash) {
      var nestedOptions;
      nestedOptions = function(scope) {
        console.log(scope);
        return '<select class="form-control" data-ng-model="model.topic.id" data-ng-init="model.topic.id = model.topic.id || model.ancestral_topic.id" style="width: 100%; ' + 'max-width:600px;" convert-to-number data-ng-change="updateTopic()" data-ng-if="model.topic || !model.strand">' + '<option value=""><em>Clear</em></option>' + '<option ' + 'data-ng-repeat="topic in topics" ' + 'data-ng-selected="topic.id == model.topic.id" ' + 'data-a-topic-indent="{{topic.level}}" ' + 'class="a-topic-level-{{topic.level}}" ' + 'value="{{topic.id}}">{{topic.name}}</option>' + '</select>' + '<span class="a-topic" data-ng-if="!model.topic && model.strand">{{model.strand.topic.name}}</span>';
      };
      return {
        restrict: 'E',
        require: 'ngModel',
        scope: {
          model: '=ngModel'
        },
        link: {
          post: function($scope, iElement, iAttrs, ngModel) {
            var init;
            init = function() {
              var el;
              console.log('a topic init');
              $scope.model.orig_topic = $scope.model.topic;
              $scope.topics = DataManager.getTopics({
                flattened: true
              });
              el = $compile(nestedOptions($scope))($scope);
              return iElement.replaceWith(el);
            };
            $scope.updateTopic = function() {
              bsLoadingOverlayService.start();
              return DataManager.updateTopic($scope.model, $scope.model.topic.id).then(function() {
                return $scope.model.orig_topic = $scope.model.topic;
              }, function(reason) {
                $scope.model.topic = $scope.model.orig_topic;
                return $scope.model.errors = reason.data.message;
              })["finally"](function() {
                return bsLoadingOverlayService.stop();
              });
            };
            return init();
          }
        }
      };
    }
  ]);

  mapping.directive('aTopicIndent', [
    function() {
      return {
        restrict: 'A',
        scope: {},
        link: {
          post: function($scope, iElement, iAttrs, con) {
            return $scope.$watch('topic', function() {
              return iElement.text("--".repeat(parseInt(iAttrs.aTopicIndent) - 1) + iElement.text());
            });
          }
        }
      };
    }
  ]);

}).call(this);
