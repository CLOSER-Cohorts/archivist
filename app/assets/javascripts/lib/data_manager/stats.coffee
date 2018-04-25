stats = angular.module('archivist.data_manager.stats', [
])

stats.factory(
  'ApplicationStats',
  [
    '$http',
    ($http)->
      $http.get('/stats.json',{cache: true})
  ]
)

stats.factory(
  'InstrumentStats',
  [
    '$http',
    ($http)->
      (id)->
        $http.get('/instruments/' + id + '/stats.json',{cache: true})
  ]
)