(function() {
  var topics;

  topics = angular.module('archivist.topics', ['ngRoute', 'archivist.data_manager']);

  topics.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/topics', {
        templateUrl: 'partials/topics/index.html',
        controller: 'TopicsIndexController'
      });
    }
  ]);

  topics.controller('TopicsIndexController', [
    '$scope', '$routeParams', 'DataManager', 'Topics', function($scope, $routeParams, DataManager, Topics) {
      $scope.data = DataManager.getTopics({
        nested: true
      });
      $scope.treeOptions = {
        dirSelectable: false
      };
      $scope.showSelected = function(node, selected) {
        if (!selected) {
          $scope.node = null;
          return $scope.quesiton_stats = $scope.variable_stats = $scope.node = null;
        } else {
          $scope.node = node;
          $scope.quesiton_stats = $scope.variable_stats = null;
          console.log(node);
          console.log(Topics);
          $scope.question_stats = Topics.questionStatistics({
            id: node.id
          });
          return $scope.variable_stats = Topics.variableStatistics({
            id: node.id
          });
        }
      };
      return console.log($scope);
    }
  ]);

}).call(this);
