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
      .when('/admin/users',
        templateUrl: 'partials/admin/users.html'
        controller: 'AdminUsersController'
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
])

admin.controller('AdminUsersController',
  [
    '$scope',
    'DataManager'
    ($scope, DataManager)->
      DataManager.getUsers()
      $scope.groups = DataManager.Data.Groups
      $scope.users = []
      $scope.mode = false

      $scope.selectGroup = (group)->
        $scope.users = group.users
        $scope.current = group
        $scope.mode = 'group'

      $scope.selectUser = (user)->
        $scope.current = user
        $scope.mode = 'user'

      $scope.newGroup = ->
        $scope.current = new DataManager.Users.Groups.resource()
        $scope.current.study = ['']
        $scope.current.new_study = null
        $scope.mode = 'group'

      $scope.addStudy = ->
        $scope.current.study.push ''

  ])

admin.controller('AdminInstrumentsController',
  [
    '$scope',
    'DataManager'
    ($scope, DataManager)->
      $scope.instruments = DataManager.Instruments.query()
      $scope.pageSize = 16
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
      $scope.uploadImport = (model)->
        console.log $scope
        fd = new FormData()
        fd.append model+'[]', $scope[model]
        $http({
          method: 'POST'
          url: '/admin/import/instruments'
          data: fd
          transformRequest: angular.identity
          headers :
            'Content-Type': undefined
        }).success(->
          Flash.add('success', 'Instrument imported.')
        ).error(->
          Flash.add('danger', 'Instrument failed to import.')
        )
])

admin.directive('fileModel',
  [
    '$parse',
    ($parse)->
      {
        restrict: 'A',
        link: (scope, element, attrs)->
          model = $parse(attrs.fileModel)
          modelSetter = model.assign

          element.bind 'change', ->
            scope.$apply ->
              modelSetter(scope, element[0].files[0])
      }
])