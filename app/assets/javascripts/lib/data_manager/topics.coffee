topics = angular.module(
  'archivist.data_manager.topics',
  [
    'archivist.resource'
  ]
)

topics.factory(
  'Topics',
  [
    'WrappedResource',
    (WrappedResource)->
      wr = new WrappedResource(
        'topics/:id.json',
        {id: '@id'},
        {
          getNested: {
            method: 'GET',
            url: '/topics/nested_index.json'
            isArray: true
          },
          getFlattenedNest: {
            method: 'GET',
            url: '/topics/flattened_nest.json'
            isArray: true
          },
          questionStatistics: {
            method: 'GET',
            url: '/topics/:id/question_statistics.json',
            isArray: true
          },
          variableStatistics: {
            method: 'GET',
            url: '/topics/:id/variable_statistics.json',
            isArray: true
          },
          save: {
            method: 'PUT'
          },
          create: {
            method: 'POST'
          }
        }
      )

      wr.questionStatistics = (parameters, success, error)->
        wr.resource.questionStatistics parameters, success, error

      wr.variableStatistics = (parameters, success, error)->
        wr.resource.variableStatistics parameters, success, error

      wr.getNested = (parameters, success, error)->
        if not wr.data['getNested']?
          wr.data['getNested'] = wr.resource.getNested parameters, success, error
        wr.data['getNested']

      wr.regetNested = (parameters, success, error)->
        wr.data['getNested'] = null
        wr.getNested parameters, success, error

      wr.getFlattenedNest = (parameters, success, error)->
        if not wr.data['getFlattenedNest']?
          wr.data['getFlattenedNest'] = wr.resource.getFlattenedNest parameters, success, error
        wr.data['getFlattenedNest']

      wr.regetFlattenedNest = (parameters, success, error)->
        wr.data['getFlattenedNest'] = null
        wr.getFlattenedNest parameters, success, error

      wr
  ]
)