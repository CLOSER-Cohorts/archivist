class Archivist.Models.ControlConstruct extends Backbone.Model
  paramRoot: 'control_construct'

  defaults:
    label: null
    construct: null
    parent: null
    position: null
    branch: null

class Archivist.Collections.ControlConstructsCollection extends Backbone.Collection
  model: Archivist.Models.ControlConstruct
  url: '/control_constructs'
