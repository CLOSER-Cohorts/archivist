class Archivist.Models.CcLoop extends Backbone.Model
  paramRoot: 'cc_loop'

  defaults:
    loop_var: null
    start_val: null
    end_val: null
    loop_while: null

class Archivist.Collections.CcLoopsCollection extends Backbone.Collection
  model: Archivist.Models.CcLoop
  url: '/cc_loops'
