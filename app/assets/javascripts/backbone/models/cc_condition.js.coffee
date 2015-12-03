class Archivist.Models.CcCondition extends Backbone.Model
  paramRoot: 'cc_condition'

  defaults:
    literal: null
    logic: null

class Archivist.Collections.CcConditionsCollection extends Backbone.Collection
  model: Archivist.Models.CcCondition
  url: '/cc_conditions'
