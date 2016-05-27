rds = angular.module('archivist.data_manager.response_domains', [
  'archivist.data_manager.response_domains.codes',
  'archivist.data_manager.response_domains.datetimes',
  'archivist.data_manager.response_domains.numerics',
  'archivist.data_manager.response_domains.texts'
])

rds.factory(
  'ResponseDomains',
  [
    'ResponseDomainDatetimes',
    'ResponseDomainNumerics',
    'ResponseDomainTexts',
    'ResponseDomainCodes',
    (
      ResponseDomainDatetimes,
      ResponseDomainNumerics,
      ResponseDomainTexts,
      ResponseDomainCodes
    )->
      ResponseDomains = {}

      ResponseDomains.Datetimes        = ResponseDomainDatetimes
      ResponseDomains.Numerics         = ResponseDomainNumerics
      ResponseDomains.Texts            = ResponseDomainTexts
      ResponseDomains.Codes            = ResponseDomainCodes

      ResponseDomains.clearCache = ->
        ResponseDomains.Datetimes.clearCache()
        ResponseDomains.Numerics.clearCache()
        ResponseDomains.Texts.clearCache()
        ResponseDomains.Codes.clearCache()

      ResponseDomains
  ]
)