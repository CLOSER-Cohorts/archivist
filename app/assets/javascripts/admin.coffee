admin = angular.module('archivist.admin', [
  'templates',
  'ngRoute'
])

admin.config(['$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/admin',
        templateUrl: 'partials/admin/index.html'
        controller: 'AdminController'
      )
      .when('/admin/import',
        templateUrl: 'partials/admin/import.html'
        controller: 'AdminController'
      )
])

admin.controller('AdminController',
  [
    '$scope',
    ($scope)->
      $scope.counts = []
      $scope.counts.instruments = 68
      $scope.counts.questions = 3021
      $scope.counts.variables = 687
      $scope.counts.users = 1
])

admin.controller('FileUploadController',
  [
    '$scope',
    '$http',
    '$filter',
    '$window',
    ($scope, $http)->
      $scope.options =
        url: '/admin/import'
      $scope.loadingFiles = true;
      $http.get $scope.options.url
        .then(
          (response)->
            $scope.loadingFiles = false
            $scope.queue = response.data.files || []
          ,()->
            $scope.loadingFiles = false
        )
])