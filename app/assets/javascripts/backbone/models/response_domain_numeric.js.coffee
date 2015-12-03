class Archivist.Models.ResponseDomainNumeric extends Backbone.Model
  paramRoot: 'response_domain_numeric'

  defaults:
    numeric_type: null
    label: null
    min: null
    max: null

class Archivist.Collections.ResponseDomainNumericsCollection extends Backbone.Collection
  model: Archivist.Models.ResponseDomainNumeric
  url: '/response_domain_numerics'
