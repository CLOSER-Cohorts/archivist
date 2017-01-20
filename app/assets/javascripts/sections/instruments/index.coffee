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
    'DataManager'
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
        console.log params
        # debugger
        $http {
          method: 'POST'
          url: '/instruments/'+$scope.instrument.id+'/imports.json'
          data: JSON.stringify params
        }
        .success ->
          Flash.add 'success', 'Instrument imported.'
          console.log 'success'
        .error (res)->
          console.log 'error'
          console.log res.message

      PushToArray = (fileType, files, array) ->
        count = 0
        while count < files.length
          array.push
            type: fileType
            file: files[count].base64
          count++
        array

      $scope.importInstrument = ()->
        $scope.publish_flash()

        params = {}
        imports = []
        files = []
        if $scope.mapping
          imports = PushToArray('mapping',$scope.mapping.file,imports)
        if $scope.dv
          imports = PushToArray('dv',$scope.dv.file,imports)
        if $scope.topicv
          imports = PushToArray('topicv',$scope.topicv.file,imports)
        if $scope.topicq
          imports = PushToArray('topicq',$scope.topicq.file,imports)

        params.imports = imports
        DoImportPost(params)
])
