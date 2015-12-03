class Archivist.Models.Code extends Backbone.Model
  paramRoot: 'code'

  defaults:
    value: null
    order: null
    code_list: null
    category: null

class Archivist.Collections.CodesCollection extends Backbone.Collection
  model: Archivist.Models.Code
  url: '/codes'
