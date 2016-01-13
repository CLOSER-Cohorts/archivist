loops = angular.module('archivist.loops', [
  'templates',
  'ngRoute',
  'ngResource',
])

loops.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
    .when('instruments/:instrument_id/loops',
      templateUrl: 'partials/loops/index.html'
      controller: 'LoopsController'
    )
    .when('instruments/:instrument_id/loops/:id',
      templateUrl: 'partials/loops/show.html'
      controller: 'LoopsController'
    )
])

loops.factory('LoopsArchive', [ '$resource',
  ($resource)->
    $resource('instruments/:instrument_id/cc_loops/:id.json', {}, {
      query: {method: 'GET', isArray: true}
    })
])

loops.controller('LoopsController', [ '$scope', '$routeParams', 'LoopsArchive',
  ($scope, $routeParams, Archive)->
    if $routeParams.id
      $scope.loop = Archive.get {instrument_id: $routeParams.instrument_id, id: $routeParams.id}
    else
      $scope.loops = Archive.query()
])