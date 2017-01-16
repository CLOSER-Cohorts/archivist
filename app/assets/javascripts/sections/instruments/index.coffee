#= require_self
#= require ./modules

instruments = angular.module('archivist.instruments', [
  'templates',
  'ngRoute',
  'ngResource',
  'ui.bootstrap',
  'archivist.flash',
  'archivist.data_manager',
  'naif.base64'
])

instruments.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/instruments',
        templateUrl: 'partials/instruments/index.html'
        controller: 'InstrumentsController'
      )
      .when('/instruments/:id',
        templateUrl: 'partials/instruments/show.html'
        controller: 'InstrumentsController'
      )
      .when('/instruments/:id/edit',
        templateUrl: 'partials/instruments/edit.html'
        controller: 'InstrumentsController'
      )
      .when('/instruments/:id/import',
        templateUrl: 'partials/instruments/import.html'
        controller: 'InstrumentsController'
      )
])

instruments.controller('InstrumentsController',
  [
    '$scope',
    '$routeParams',
    '$location',
    '$q',
    '$http',
    '$timeout',
    'Flash',
    'DataManager',
    'Base64Factory'
    ($scope, $routeParams, $location, $q, $http, $timeout, Flash, DataManager, Base64Factory)->
      $scope.page['title'] = 'Instruments'
      if $routeParams.id
        loadStructure = $location.path().split("/")[$location.path().split("/").length - 1].toLowerCase() != 'edit'
        loadStudies = !loadStructure

        $scope.loading = {state: "Downloading", progress: 0, type: "info"}
        progressUpdate = (newValue)->
          $scope.loading.progress = newValue
          if $scope.loading.progress > 99
            $scope.loading.state = "Processing"
            $scope.loading.type = "success"


        $scope.instrument = DataManager.getInstrument $routeParams.id,
          {
            constructs: loadStructure,
            questions: loadStructure,
            progress: progressUpdate
          },
          ()->
            $scope.page['title'] = $scope.instrument.prefix + ' | Edit'
            $timeout(->
              if loadStructure
                $scope.page['title'] = $scope.instrument.prefix + ' | View'
                DataManager.resolveConstructs()
                DataManager.resolveQuestions()
                $scope.breadcrumbs = [
                  {
                    label: 'Instruments',
                    link: '/instruments',
                    active: false
                  },
                  {
                    label: $scope.instrument.prefix,
                    link: false,
                    active: false,
                    subs: [
                      {label: 'Build', link: '/instruments/' + $routeParams.id + '/build'}
                    ]
                  },
                  {
                    label: 'View',
                    link: false,
                    active: true
                  }
                ]
                console.log $scope
              $scope.loading.state = "Done"
            , 100)

      else
        $scope.instruments = DataManager.getInstruments()
        $scope.pageSize = 20
        $scope.filterStudy = (study)->
          $scope.filteredStudy = study

        #TODO: Move to DataManager at some point
        $http.get('/studies.json').success((data)->
          $scope.studies = data
        )

      $scope.updateInstrument = ->
        $scope.instrument.$save(
          {}
          ,->
            Flash.add('success', 'Instrument updated successfully!')
            $location.path('/instruments')
            DataManager.clearCache()
          ,->
            console.log("error")
        )

      DoImportPost = (params) ->
        console.log 'inside DoImportPost'
        # debugger
        $http {
          method: 'POST'
          url: '/instruments/'+$scope.instrument.id+'/imports.json'
          data: params
        }
        .success ->
          Flash.add 'success', 'Instrument imported.'
          console.log 'success'
        .error (res)->
          console.log 'error'
          console.log res.message


      $scope.importInstrument = ()->
        $scope.publish_flash()

        params = {}
        imports = []
        files = []
        if $scope.import
          files.push({file:$scope.import.file})
          imports.push({type:$scope.import.type,file:$scope.import.file[0].base64})
          debugger
          # promiseMapping = Base64Factory.getBase64($scope.import.file)
          # promiseMapping.then ((data) ->
          #   console.log 'then'
          #   imports.push({type:$scope.import.type,file:data.split(',')[1]})
          #   params.imports = imports
          #   # DoImportPost(params)
          # ), (error) ->
          #   console.log 'error' +error

])

instruments.factory 'Base64Factory', ($q) ->
  { getBase64: (file) ->
    deferred = $q.defer()
    readerFile = new FileReader
    readerFile.readAsDataURL file

    readerFile.onload = ->
      deferred.resolve readerFile.result
      return

    readerFile.onerror = (error) ->
      deferred.reject error
      return

    deferred.promise
 }
