class Archivist.Models.ResponseDomainCode extends Backbone.Model
  paramRoot: 'response_domain_code'

  defaults:
    code_list: null

class Archivist.Collections.ResponseDomainCodesCollection extends Backbone.Collection
  model: Archivist.Models.ResponseDomainCode
  url: '/response_domain_codes'
