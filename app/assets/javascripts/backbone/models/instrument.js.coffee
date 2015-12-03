class Archivist.Models.Instrument extends Backbone.Model
  paramRoot: 'instrument'

  defaults:
    agency: null
    version: null
    prefix: null
    label: null
    study: null

class Archivist.Collections.InstrumentsCollection extends Backbone.Collection
  model: Archivist.Models.Instrument
  url: '/instruments'
