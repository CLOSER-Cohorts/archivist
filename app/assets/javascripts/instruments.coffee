instruments = angular.module('archivist.instruments', [
  'templates',
  'ngRoute',
  'ngResource',
  'archivist.conditions',
  'archivist.loops',
  'archivist.questions',
  'archivist.sequences',
  'archivist.statements',
])

instruments.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/instruments',
        templateUrl: 'partials/instruments/index.html'
        controller: 'InstrumentsController'
      )
      .when('/instruments/:id',
        templateUrl: 'partials/instruments/show.html'
        controller: 'InstrumentsController'
      )
])

instruments.factory('InstrumentsArchive', [ '$resource',
  ($resource)->
    $resource('instruments/:id.json', {}, {
      query: {method: 'GET', isArray: true}
    })
])

instruments.factory('InstrumentRelationshipResolver', [
  ->
    (instruments, reference)->
      switch reference.type
        when "CcCondition" then instruments.conditions.select_resource_by_id reference.id
        when "CcLoop" then instruments.loops.select_resource_by_id reference.id
        when "CcQuestion" then instruments.questions.select_resource_by_id reference.id
        when "CcSequence" then instruments.sequences.select_resource_by_id reference.id
        when "CcStatement" then instruments.statements.select_resource_by_id reference.id
        else #throw an error
])

instruments.controller('InstrumentsController',
  [
    '$scope',
    '$routeParams',
    '$q',
    'InstrumentRelationshipResolver',
    'QuestionResolver',
    'InstrumentsArchive',
    'ConditionsArchive',
    'LoopsArchive',
    'QuestionsArchive',
    'SequencesArchive',
    'StatementsArchive',
    ($scope, $routeParams, $q, ResolveRelationship, ResolveQuestion, Archive, Conditions, Loops, Questions, Sequences, Statements)->
      if $routeParams.id
        $scope.instrument = Archive.get {id: $routeParams.id}, ->
          $scope.instrument.conditions = Conditions.query({instrument_id: $routeParams.id})
          $scope.instrument.loops = Loops.query({instrument_id: $routeParams.id})
          $scope.instrument.questions = Questions.cc.query({instrument_id: $routeParams.id})
          $scope.instrument.qitems = Questions.item.query({instrument_id: $routeParams.id})
          $scope.instrument.qgrids = Questions.grid.query({instrument_id: $routeParams.id})
          $scope.instrument.sequences = Sequences.query({instrument_id: $routeParams.id})
          $scope.instrument.statements = Statements.query({instrument_id: $routeParams.id})

          $q.all([
            $scope.instrument.conditions.$promise,
            $scope.instrument.loops.$promise,
            $scope.instrument.questions.$promise,
            $scope.instrument.qitems.$promise,
            $scope.instrument.qgrids.$promise,
            $scope.instrument.sequences.$promise,
            $scope.instrument.statements.$promise
          ]).then(->
            for sequence in $scope.instrument.sequences
              sequence.type = 'sequence'
              if sequence.children?
                sequence.children = (ResolveRelationship($scope.instrument, child) for child in sequence.children)

            for condition in $scope.instrument.conditions
              condition.type = 'condition'
              if condition.children?
                condition.children = (ResolveRelationship($scope.instrument, child) for child in condition.children)

            for lp in $scope.instrument.loops
              lp.type = 'loop'
              if lp.children?
                lp.children = (ResolveRelationship($scope.instrument, child) for child in lp.children)

            for question in $scope.instrument.questions
              question.type = 'question'
              console.log(question)
              question.base = ResolveQuestion.base($scope.instrument, question)
              console.log(question)

            for statement in $scope.instrument.statements
              statement.type = 'statement'

            $scope.instrument.topsequence = (sequence for sequence in $scope.instrument.sequences when sequence.top)[0]
          )

      else
        $scope.instruments = Archive.query(
          ->
            $scope.studies = (instrument.study for instrument in $scope.instruments).unique().sort()
        )
        $scope.filterStudy = (study)->
          $scope.filteredStudy = study
])