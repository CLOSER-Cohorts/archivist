instruments = angular.module('archivist.instruments', [
  'templates',
  'ngRoute',
  'ngResource',
  'archivist.sequences',
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
])

instruments.factory('InstrumentsArchive', [ '$resource',
  ($resource)->
    $resource('instruments/:id.json', {}, {
      query: {method: 'GET', isArray: true}
    })
])

instruments.controller('InstrumentsController',
  [
    '$scope',
    '$routeParams',
    'InstrumentsArchive',
    'SequencesArchive',
    ($scope, $routeParams, Archive, Sequences)->
      if $routeParams.id
        $scope.instrument = Archive.get {id: $routeParams.id}, ->
          $scope.instrument.sequences = Sequences.query({instrument_id: $routeParams.id})
      else
        $scope.instruments = Archive.query(
          ->
            $scope.studies = (instrument.study for instrument in $scope.instruments).unique().sort()
        )
        $scope.filterStudy = (study)->
          $scope.filteredStudy = study
])