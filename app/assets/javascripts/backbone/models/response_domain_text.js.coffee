class Archivist.Models.ResponseDomainText extends Backbone.Model
  paramRoot: 'response_domain_text'

  defaults:
    label: null
    maxlen: null

class Archivist.Collections.ResponseDomainTextsCollection extends Backbone.Collection
  model: Archivist.Models.ResponseDomainText
  url: '/response_domain_texts'
