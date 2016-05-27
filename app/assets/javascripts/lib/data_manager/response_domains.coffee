rds = angular.module('archivist.data_manager.response_domains', [
  'archivist.data_manager.response_domains.datetimes',
  'archivist.data_manager.response_domains.numerics',
  'archivist.data_manager.response_domains.texts'
])

rds.factory(
  'ResponseDomains',
  [
    'Datetimes',
    'Numerics',
    'Texts',
    (
      Datetimes,
      Numerics,
      Texts
    )->
      ResponseDomains = {}

      ResponseDomains.Datetimes        = Datetimes
      ResponseDomains.Numerics         = Numerics
      ResponseDomains.Texts            = Texts

      ResponseDomains.clearCache = ->
        ResponseDomains.Datetimes.clearCache()
        ResponseDomains.Numerics.clearCache()
        ResponseDomains.Texts.clearCache()

      ResponseDomains
  ]
)