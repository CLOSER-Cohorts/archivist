class Archivist.Models.CcStatement extends Backbone.Model
  paramRoot: 'cc_statement'

  defaults:
    literal: null

class Archivist.Collections.CcStatementsCollection extends Backbone.Collection
  model: Archivist.Models.CcStatement
  url: '/cc_statements'
