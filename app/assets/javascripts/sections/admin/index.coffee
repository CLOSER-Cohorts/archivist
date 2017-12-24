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
    .when('/admin/datasets',
      templateUrl: 'partials/admin/datasets.html'
      controller: 'AdminDatasetsController'
    )
    .when('/admin/users',
      templateUrl: 'partials/admin/users.html'
      controller: 'AdminUsersController'
    )
    .when('/admin/import',
      templateUrl: 'partials/admin/import.html'
      controller: 'AdminImportController'
    )
    .when('/admin/export',
      templateUrl: 'partials/admin/export.html'
      controller: 'AdminExportController'
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
    'DataManager',
    'Flash'
    ($scope, DataManager, Flash)->
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
        $scope.users = []
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
          if $scope.mode == 'group'
            $scope.groups.push $scope.current
          else
            DataManager.Data.Users.push $scope.current
            DataManager.GroupResolver.resolve()

          $scope.original = $scope.current
        $scope.original.save(
          {},
          (a, b, c, d, e)->
            $scope.editing = false
          ,->
            $scope.original = null
            Flash.add 'danger', 'Could not save '+ $scope.mode + '.'
        )

      $scope.reset_password = ->
        console.log $scope
        $scope.current.$reset_password()

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
    '$http',
    'AdminMappingImportsFactory',
    ($scope, DataManager, Flash, $http, AdminMappingImportsFactory)->
      $scope.instruments = DataManager.Instruments.query()
      $scope.pageSize = 16
      $scope.confirmation = {prefix: ''}
      $scope.mapping = {}

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
              console.error response
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

      $scope.cleanInputImport = ->
        if $scope.mapping.files
          $scope.mapping.files = undefined

      $scope.clearCache = (id)->
        $scope.instruments.select_resource_by_id(id).$clear_cache()

      $scope.prepareImport = (prefix,id)->
        $scope.id = id
        $scope.modal={}
        $scope.modal.title = prefix
        $scope.modal.msgFileType = "Q-V and T-Q"
        $scope.modal.fileTypes = [{value:'qvmapping', label:'Q-V Mapping'},
                                  {value:'topicq', label:'T-Q Mapping'}]

      $scope.import = (id) ->
        AdminMappingImportsFactory.import($scope.mapping.files, $scope.mapping.type, 'POST', '/instruments/' + $scope.id + '/imports.json').then ((response) ->
          if response.status == 200
            Flash.add 'success', 'File imported.'
          else
            Flash.add 'danger', 'Something went wrong, please import the file again.'
        ), (error) ->
          Flash.add 'danger', 'Something went wrong, please import the file again.'

  ])

admin.controller('AdminDatasetsController',[
  '$scope',
  'DataManager',
  'Flash',
  '$http',
  'AdminMappingImportsFactory',
  ($scope, DataManager, Flash, $http,AdminMappingImportsFactory)->
    $scope.datasets = DataManager.getDatasets()
    $scope.pageSize = 20
    $scope.mapping = {}

    $scope.prepareImport = (name,id)->
      $scope.id = id
      $scope.modal={}
      $scope.modal.title = name
      $scope.modal.msgFileType = "T-V and DV"
      $scope.modal.fileTypes = [{value:'topicv', label:'T-V Mapping'},
                                {value:'dv', label:'DV Mapping'}]

    $scope.import = (id) ->
      AdminMappingImportsFactory.import($scope.mapping.files, $scope.mapping.type, 'POST', '/datasets/' + $scope.id + '/imports.json').then ((response) ->
        if response.status == 200
          Flash.add 'success', 'File imported.'
        else
          Flash.add 'danger', 'Something went wrong, please import the file again.'
      ), (error) ->
        console.log error
        Flash.add 'danger', 'Something went wrong, please import the file again.'

    $scope.prepareDelete = (id)->
      $scope.dataset = $scope.datasets.select_resource_by_id(id)

    $scope.delete = ->
      $scope.dataset.$delete {},
        ->
          DataManager.Data = {}
          $scope.datasets = DataManager.Dataset.requery()
          Flash.add 'success', 'Dataset deleted successfully'
      ,
        (response)->
          console.error response
          Flash.add 'danger', 'Failed to delete dataset - ' + response.message
  ])

admin.controller('AdminImportController',
  [
    '$scope',
    '$http',
    'Flash'
    ($scope, $http, Flash)->
      $scope.files = []
      $scope.options =
        question_grids: true

      $scope.uploadInstrumentImport = ()->
        $scope.publish_flash()
        fd = new FormData()
        angular.forEach $scope.files, (item) ->
          fd.append 'files[]', item

        possible_options = [
          'question_grids',
          'instrument_prefix',
          'instrument_agency',
          'instrument_label',
          'instrument_study'
        ]
        for key in possible_options
          if $scope.options[key]?
            fd.set key, $scope.options[key]

        if $scope.options
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

      $scope.uploadDatasetImport = ()->
        $scope.publish_flash()
        fd = new FormData()
        angular.forEach $scope.files, (item) ->
          fd.append 'files[]', item
        $http {
          method: 'POST'
          url: '/admin/import/datasets'
          data: fd
          transformRequest: angular.identity
          headers :
            'Content-Type': undefined
        }
        .success ->
          Flash.add 'success', 'Dataset imported.'
        .error (res)->
          Flash.add 'danger', 'Dataset failed to import - ' + res.message
  ])

admin.controller('AdminExportController',
  [
    '$scope',
    '$http',
    'DataManager',
    ($scope, $http, DataManager)->
      $scope.instruments = DataManager.Instruments.query({}, (instruments)->
        angular.forEach(instruments, (v,k)->
          v.can_export = (Date.parse(v.export_time) < Date.parse(v.last_edited_time)) || v.export_time == null
          v.has_export = v.export_url != null
        )
      )
      $scope.pageSize = 24

      console.log $scope

      $scope.export = (instrument)->
        $http.get '/instruments/' + instrument.id.toString() + '/export.json'
  ])

admin.factory('AdminMappingImportsFactory',
  [
    '$http',
    '$q',
    ($http,$q)->

      MappingImports = {}

      MappingImports.import = (files,filetype,method,url) ->
        i = 0
        params = {}
        params.imports=[]

        while i < files.length
          data = {file:files[i].base64, type:filetype[i]}
          params.imports.push(data)
          i++

        $http {
          method: method
          url: url
          data: JSON.stringify params
        }
        .then ((res) ->
          console.log 'imported'
          console.log res
          res
        ), (res)->
          console.log res
          $q.reject(res)

      MappingImports

  ])
