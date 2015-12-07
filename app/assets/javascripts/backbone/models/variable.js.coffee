class Archivist.Models.Variable extends Backbone.Model
  paramRoot: 'variable'

  defaults:
    name: null
    label: null
    var_type: null
    dataset: null

class Archivist.Collections.VariablesCollection extends Backbone.Collection
  model: Archivist.Models.Variable
  url: '/variables'
