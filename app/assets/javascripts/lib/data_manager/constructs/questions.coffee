questions = angular.module('archivist.data_manager.constructs.questions', [
  'archivist.resource',
])

questions.factory(
  'Questions',
  [
    'WrappedResource',
    (WrappedResource)->
      {
        cc: new WrappedResource('instruments/:instrument_id/cc_questions/:id.json')

        item: new WrappedResource('instruments/:instrument_id/question_items/:id.json')

        grid: new WrappedResource('instruments/:instrument_id/question_grids/:id.json')
      }
  ]
)