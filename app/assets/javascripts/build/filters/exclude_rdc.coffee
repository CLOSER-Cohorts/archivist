angular.module('archivist.build').filter(
  'excludeRDC',
  ->
    (items)->
      output = []
      angular.forEach items, (item)->
        if item.type != 'ResponseDomainCode'
          output.push item
      output
)