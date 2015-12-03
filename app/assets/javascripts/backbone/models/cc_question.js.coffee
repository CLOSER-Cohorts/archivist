class Archivist.Models.CcQuestion extends Backbone.Model
  paramRoot: 'cc_question'

  defaults:
    question: null

class Archivist.Collections.CcQuestionsCollection extends Backbone.Collection
  model: Archivist.Models.CcQuestion
  url: '/cc_questions'
