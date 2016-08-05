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
      $scope.editing = false

      $scope.selectGroup = (group)->
        $scope.users = group.users
        $scope.current = group
        $scope.mode = 'group'
        $scope.editing = false

      $scope.selectUser = (user)->
        $scope.current = user
        $scope.mode = 'user'
        $scope.editing = false

      $scope.newGroup = ->
        $scope.original = null
        $scope.current = new DataManager.Auth.Groups.resource()
        $scope.current.study = [{label:''}]
        $scope.mode = 'group'
        $scope.editing = true

      $scope.newUser = ->
        $scope.original = null
        $scope.current = new DataManager.Auth.Users.resource()
        $scope.mode = 'user'
        $scope.editing = true

      $scope.addStudy = ->
        $scope.current.study.push {label:''}

      $scope.edit = ->
        $scope.original = $scope.current
        $scope.current = null
        $scope.current = angular.copy $scope.original
        $scope.editing = true

      $scope.cancel = ->
        if $scope.original?
          $scope.current = $scope.original
        else
          $scope.current = null
          $scope.mode = false
        $scope.editing = false

      $scope.save = ->
        console.log $scope
        if $scope.original?
          angular.copy $scope.current, $scope.original
        else
          (if $scope.mode = 'group' then $scope.groups else DataManager.Data.Users).push $scope.current
          $scope.original = $scope.current
        $scope.original.save(
          {},
          ->
            $scope.editing = false
        )

      $scope.delete = ->
        arr = if $scope.mode = 'group' then $scope.groups else DataManager.Data.Users
        index = arr.indexOf $scope.current
        arr[index].$delete(
          {},
          ->
            arr.splice index, 1
        )

      $scope.only_group_check = ->
        if $scope.groups.length == 1
          $scope.selectGroup $scope.groups[$scope.groups.length - 1]

      $scope.groups.$promise.then ->
        $scope.only_group_check()
  ])

admin.controller('AdminInstrumentsController',
  [
    '$scope',
    'DataManager',
    'Flash',
    ($scope, DataManager, Flash)->
      $scope.instruments = DataManager.Instruments.query()
      $scope.pageSize = 16
      $scope.confirmation = {prefix: ''}

      $scope.prepareCopy = (id)->
        $scope.original = $scope.instruments.select_resource_by_id(id)
        $scope.copiedInstrument = {}
        $scope.copiedInstrument['new_study'] = $scope.original.study
        $scope.copiedInstrument['new_agency'] = $scope.original.agency
        $scope.copiedInstrument['new_version'] = $scope.original.version

      $scope.copy = ->
        $scope.copiedInstrument = $scope.original.$copy $scope.copiedInstrument
        ,  ->
            Flash.add 'success', 'Instrument copied successfully'
        ,
          (response)->
            Flash.add 'danger', 'Instrument failed to copy - ' + response.message


      $scope.prepareDelete = (id)->
        $scope.instrument = $scope.instruments.select_resource_by_id(id)

      $scope.delete = ->
        if $scope.confirmation.prefix == $scope.instrument.prefix
          $scope.instrument.$delete {},
            ->
              DataManager.Data = {}
              $scope.instruments = DataManager.Instruments.requery()
              Flash.add 'success', 'Instrument deleted successfully'
          ,
            (response)->
              console.log response
              Flash.add 'danger', 'Failed to delete instrument - ' + response.message
        else
          Flash.add 'danger', 'The prefixes did not match. The instrument was not deleted.'

        $scope.confirmation.prefix = ''

      $scope.prepareNew = ->
        $scope.newInstrument = new DataManager.Instruments.resource()

      $scope.new = ->
        $scope.newInstrument.$create {},
          ->
            Flash.add 'success', 'New instrument created successfully'
        ,
          (response)->
            Flash.add 'danger', 'Failed to create new instrument - ' + response.message
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
        $http {
          method: 'POST'
          url: '/admin/import/instruments'
          data: fd
          transformRequest: angular.identity
          headers :
            'Content-Type': undefined
        }
        .success ->
          Flash.add 'success', 'Instrument imported.'
        .error (res)->
          Flash.add 'danger', 'Instrument failed to import - ' + res.message
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