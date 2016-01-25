questions = angular.module('archivist.data_manager.constructs.questions', [
  'ngResource',
])

questions.factory(
  'Questions',
  [
    '$resource',
    ($resource)->
      {
        cc: $resource('instruments/:instrument_id/cc_questions/:id.json', {}, {
          query: {method: 'GET', isArray: true}
        })

        item: $resource('instruments/:instrument_id/question_items/:id.json', {}, {
          query: {method: 'GET', isArray: true}
        })

        grid: $resource('instruments/:instrument_id/question_grids/:id.json', {}, {
          query: {method: 'GET', isArray: true}
        })
      }
  ]
)

questions.factory(
  'QuestionResolver',
  [
    ->
      {
        base:(instrument, cc)->
          switch cc.question_type
            when "QuestionItem" then instrument.qitems.select_resource_by_id(cc.question_id)
            when "QuestionGrid" then instrument.qgrids.select_resource_by_id(cc.question_id)
            else #throw an error

        cc:(instrument, base)->
          (question for question in instrument.questions when question.question_id == base.id)[0]
      }
  ]
)