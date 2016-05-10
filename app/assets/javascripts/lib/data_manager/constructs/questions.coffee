questions = angular.module('archivist.data_manager.constructs.questions', [
  'archivist.resource',
])

questions.factory(
  'Questions',
  [
    'WrappedResource',
    (WrappedResource)->
      {
        cc: new WrappedResource(
          'instruments/:instrument_id/cc_questions/:id.json',
          {id: '@id', instrument_id: '@instrument_id'}
        )

        item: new WrappedResource(
          'instruments/:instrument_id/question_items/:id.json',
          {id: '@id', instrument_id: '@instrument_id'}
        )

        grid: new WrappedResource(
          'instruments/:instrument_id/question_grids/:id.json',
          {id: '@id', instrument_id: '@instrument_id'}
        )

        clearCache: ->
          cc.clearCache() if cc?
          item.clearCache() if item?
          grid.clearCache() if grid?
      }
  ]
)