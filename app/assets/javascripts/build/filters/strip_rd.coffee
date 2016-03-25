angular.module('archivist.build').filter(
  'stripRD',
  ->
    (item)->
      item.replace 'ResponseDomain', ''
)