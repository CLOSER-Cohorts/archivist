conditions = angular.module('archivist.data_manager.constructs.conditions', [
  'archivist.resource',
])

conditions.factory(
  'Conditions',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:instrument_id/cc_conditions/:id.json',
        {
          id: '@id',
          instrument_id: '@instrument_id'
        },
        {
          save:           {method: 'PUT'},
          create:         {method: 'POST'},
          update_topic:   {method: 'POST', url: 'instruments/:instrument_id/cc_conditions/:id/set_topic.json'}
        }
      )
  ]
)