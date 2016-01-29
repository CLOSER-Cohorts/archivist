admin = angular.module('archivist.admin', [
  'templates',
  'ngRoute',
  'archivist.data_manager'
])

admin.config(['$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/admin',
        templateUrl: 'partials/admin/index.html'
        controller: 'AdminDashController'
      )
      .when('/admin/instruments',
        templateUrl: 'partials/admin/instruments.html'
        controller: 'AdminInstrumentsController'
      )
      .when('/admin/import',
        templateUrl: 'partials/admin/import.html'
      )
])

admin.controller('AdminDashController',
  [
    '$scope',
    ($scope)->
      $scope.counts = []
      $scope.counts.instruments = 68
      $scope.counts.questions = 3021
      $scope.counts.variables = 687
      $scope.counts.users = 1
])

admin.controller('AdminInstrumentsController',
  [
    '$scope',
    'DataManager'
    ($scope, DataManager)->
      $scope.instruments = DataManager.Instruments.query()
      $scope.pageSize = 8

      $scope.prepareCopy = (id)->
        $scope.original = $scope.instruments.select_resource_by_id(id)
        $scope.copiedInstrument = new DataManager.Instruments.resource()
        $scope.copiedInstrument.study = $scope.original.study
        $scope.copiedInstrument.agency = $scope.original.agency
        $scope.copiedInstrument.version = $scope.original.version

      $scope.copy = ->
        $scope.copiedInstrument.$save()
        $scope.copiedInstrument.copy($scope.original.id)
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