statements = angular.module('archivist.statements', [
  'templates',
  'ngRoute',
  'ngResource',
])

statements.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
    .when('instruments/:instrument_id/statements',
      templateUrl: 'partials/statements/index.html'
      controller: 'StatementsController'
    )
    .when('instruments/:instrument_id/statements/:id',
      templateUrl: 'partials/statements/show.html'
      controller: 'StatementsController'
    )
])

statements.factory('StatementsArchive', [ '$resource',
  ($resource)->
    $resource('instruments/:instrument_id/cc_statements/:id.json', {}, {
      query: {method: 'GET', isArray: true}
    })
])

statements.controller('StatementsController', [ '$scope', '$routeParams', 'StatementsArchive',
  ($scope, $routeParams, Archive)->
    if $routeParams.id
      $scope.statement = Archive.get {instrument_id: $routeParams.instrument_id, id: $routeParams.id}
    else
      $scope.statements = Archive.query()
])