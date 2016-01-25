constructs = angular.module('archivist.data_manager.constructs', [
  'archivist.data_manager.constructs.conditions',
  'archivist.data_manager.constructs.loops',
  'archivist.data_manager.constructs.questions',
  'archivist.data_manager.constructs.sequences',
  'archivist.data_manager.constructs.statements'
])

constructs.factory(
  'Constructs',
  [
    'Conditions',
    'Loops',
    'Questions',
    'QuestionResolver',
    'Sequences',
    'Statements',
    (
      Conditions,
      Loops,
      Questions,
      QuestionResolver,
      Sequences,
      Statements,
    )->
      Constructs = {}

      Constructs.Conditions       = Conditions
      Constructs.Loops            = Loops
      Constructs.Questions        = Questions
      Constructs.QuestionResolver = QuestionResolver
      Constructs.Sequences        = Sequences
      Constructs.Statements       = Statements

      Constructs
  ]
)