admin = angular.module('archivist.admin', [
  'templates',
  'ngRoute',
  'archivist.data_manager',
  'archivist.flash'
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
        controller: 'AdminImportController'
      )
])

admin.controller('AdminDashController',
  [
    '$scope',
    'DataManager',
    ($scope, DataManager)->
      $scope.counts = DataManager.getApplicationStats()
      console.log $scope.counts
      #$scope.counts.instruments = 68
      #$scope.counts.questions = 3021
      #$scope.counts.variables = 687
      #$scope.counts.users = 1
])

admin.controller('AdminInstrumentsController',
  [
    '$scope',
    'DataManager'
    ($scope, DataManager)->
      $scope.instruments = DataManager.Instruments.query()
      $scope.pageSize = 8
      $scope.confirmation = {prefix: ''}

      $scope.prepareCopy = (id)->
        $scope.original = $scope.instruments.select_resource_by_id(id)
        $scope.copiedInstrument = new DataManager.Instruments.resource()
        $scope.copiedInstrument.study = $scope.original.study
        $scope.copiedInstrument.agency = $scope.original.agency
        $scope.copiedInstrument.version = $scope.original.version

      $scope.copy = ->
        $scope.copiedInstrument.$save()
        $scope.copiedInstrument.copy($scope.original.id)

      $scope.prepareDelete = (id)->
        $scope.instrument = $scope.instruments.select_resource_by_id(id)

      $scope.delete = ->
        if $scope.confirmation.prefix == $scope.instrument.prefix
          $scope.instrument.$delete {}, ->
            DataManager.Data = {}
            $scope.instruments = DataManager.Instruments.requery()
        else
          #TODO: Add Flash that says the delete failed

      $scope.prepareNew = ->
        $scope.newInstrument = new DataManager.Instruments.resource()

      $scope.new = ->
        $scope.newInstrument.$create()
        $scope.instruments.push $scope.newInstrument
])

admin.controller('AdminImportController',
  [
    '$scope',
    '$http',
    'Flash'
    ($scope, $http, Flash)->
      $scope.uploadImport = ()->
        $http {
          method: 'POST'
          url: '/admin/import/instruments'
          headers :
            'Content-Type': 'multipart/form-data'
        }
        Flash.add('success', 'Instrument imported.')
])
