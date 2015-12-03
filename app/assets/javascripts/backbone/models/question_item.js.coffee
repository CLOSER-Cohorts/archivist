class Archivist.Models.QuestionItem extends Backbone.Model
  paramRoot: 'question_item'

  defaults:
    label: null
    literal: null
    instruction: null

class Archivist.Collections.QuestionItemsCollection extends Backbone.Collection
  model: Archivist.Models.QuestionItem
  url: '/question_items'
