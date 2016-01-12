sequences = angular.module('archivist.sequences', [
  'templates',
  'ngRoute',
  'ngResource',
])

sequences.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
    .when('instruments/:instrument_id/sequences',
      templateUrl: 'partials/sequences/index.html'
      controller: 'SequencesController'
    )
    .when('instruments/:instrument_id/sequences/:id',
      templateUrl: 'partials/sequences/show.html'
      controller: 'SequencesController'
    )
])

sequences.factory('SequencesArchive', [ '$resource',
  ($resource)->
    $resource('instruments/:instrument_id/cc_sequences/:id.json', {}, {
      query: {method: 'GET', isArray: true}
    })
])

sequences.controller('SequencesController', [ '$scope', '$routeParams', 'SequencesArchive',
  ($scope, $routeParams, Archive)->
    if $routeParams.id
      $scope.sequence = Archive.get {instrument_id: $routeParams.instrument_id, id: $routeParams.id}
    else
      $scope.sequences = Archive.query()
])