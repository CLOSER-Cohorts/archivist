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
                console.log $scope
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
                    {
                      label: if loadStructure then 'Edit' else 'View',
                      link: '/instruments/' + $routeParams.id + if loadStructure then '/edit' else ''
                    },
                    {label: 'Build', link: '/instruments/' + $routeParams.id + '/build'},
                    {label: 'Map', link: '/instruments/' + $routeParams.id + '/map'}
                  ]
                },
                {
                  label: if loadStructure then 'View' else 'Edit',
                  link: false,
                  active: true
                }
              ]
              $scope.loading.state = "Done"
            , 100)

      else
        $scope.instruments = DataManager.getInstruments()
        $scope.pageSize = 24
        $scope.currentPage = 1
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

])

instruments.factory('Base64Factory',
  [
    '$q',
    ($q)->
      {
        getBase64: (file) ->
          deferred = $q.defer()
          readerMapping = new FileReader
          readerMapping.readAsDataURL file

          readerMapping.onload = ->
            deferred.resolve readerMapping.result
            return

          readerMapping.onerror = (error) ->
            deferred.reject error
            return

          deferred.promise
      }
])
