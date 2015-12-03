class Archivist.Models.ResponseUnit extends Backbone.Model
  paramRoot: 'response_unit'

  defaults:
    label: null

class Archivist.Collections.ResponseUnitsCollection extends Backbone.Collection
  model: Archivist.Models.ResponseUnit
  url: '/response_units'
