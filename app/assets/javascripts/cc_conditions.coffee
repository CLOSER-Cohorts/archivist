conditions = angular.module('archivist.conditions', [
  'templates',
  'ngRoute',
  'ngResource',
])

conditions.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
    .when('instruments/:instrument_id/conditions',
      templateUrl: 'partials/conditions/index.html'
      controller: 'ConditionsController'
    )
    .when('instruments/:instrument_id/conditions/:id',
      templateUrl: 'partials/conditions/show.html'
      controller: 'ConditionsController'
    )
])

conditions.factory('ConditionsArchive', [ '$resource',
  ($resource)->
    $resource('instruments/:instrument_id/cc_conditions/:id.json', {}, {
      query: {method: 'GET', isArray: true}
    })
])

conditions.controller('ConditionsController', [ '$scope', '$routeParams', 'ConditionsArchive',
  ($scope, $routeParams, Archive)->
    if $routeParams.id
      $scope.condition = Archive.get {instrument_id: $routeParams.instrument_id, id: $routeParams.id}
    else
      $scope.conditions = Archive.query()
])