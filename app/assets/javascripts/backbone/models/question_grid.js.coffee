class Archivist.Models.QuestionGrid extends Backbone.Model
  paramRoot: 'question_grid'

  defaults:
    label: null
    literal: null
    instruction: null
    vertical_code_list: null
    horizontal_code_list: null
    roster_rows: null
    roster_label: null
    corner_label: null

class Archivist.Collections.QuestionGridsCollection extends Backbone.Collection
  model: Archivist.Models.QuestionGrid
  url: '/question_grids'
