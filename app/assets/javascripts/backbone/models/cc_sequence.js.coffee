class Archivist.Models.CcSequence extends Backbone.Model
  paramRoot: 'cc_sequence'

  defaults:
    literal: null

class Archivist.Collections.CcSequencesCollection extends Backbone.Collection
  model: Archivist.Models.CcSequence
  url: '/cc_sequences'
