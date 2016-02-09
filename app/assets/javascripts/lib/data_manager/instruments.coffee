instruments = angular.module('archivist.data_manager.instruments', [
  'archivist.resource'
])

instruments.factory(
  'Instruments',
  [
    'WrappedResource',
    (WrappedResource)->
      new WrappedResource(
        'instruments/:id.json',
        {id: '@id'},
        {
          save:
            method: 'PUT'
        }
      )
  ]
)

instruments.factory(
  'InstrumentRelationshipResolver',
  [
    ->
      (instruments, reference)->
        switch reference.type
          when "CcCondition" then instruments.conditions.select_resource_by_id reference.id
          when "CcLoop" then instruments.loops.select_resource_by_id reference.id
          when "CcQuestion" then instruments.questions.select_resource_by_id reference.id
          when "CcSequence" then instruments.sequences.select_resource_by_id reference.id
          when "CcStatement" then instruments.statements.select_resource_by_id reference.id
          else #throw an error
  ]
)