class Archivist.Models.ResponseDomainDatetime extends Backbone.Model
  paramRoot: 'response_domain_datetime'

  defaults:
    datetime_type: null
    label: null
    format: null

class Archivist.Collections.ResponseDomainDatetimesCollection extends Backbone.Collection
  model: Archivist.Models.ResponseDomainDatetime
  url: '/response_domain_datetimes'
