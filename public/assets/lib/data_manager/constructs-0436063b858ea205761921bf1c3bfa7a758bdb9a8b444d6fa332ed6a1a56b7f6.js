(function() {
  var constructs;

  constructs = angular.module('archivist.data_manager.constructs', ['archivist.data_manager.constructs.conditions', 'archivist.data_manager.constructs.loops', 'archivist.data_manager.constructs.questions', 'archivist.data_manager.constructs.sequences', 'archivist.data_manager.constructs.statements']);

  constructs.factory('Constructs', [
    'Conditions', 'Loops', 'Questions', 'Sequences', 'Statements', function(Conditions, Loops, Questions, Sequences, Statements) {
      var Constructs;
      Constructs = {};
      Constructs.Conditions = Conditions;
      Constructs.Loops = Loops;
      Constructs.Questions = Questions;
      Constructs.Sequences = Sequences;
      Constructs.Statements = Statements;
      Constructs.clearCache = function() {
        Constructs.Conditions.clearCache();
        Constructs.Loops.clearCache();
        Constructs.Questions.clearCache();
        Constructs.Sequences.clearCache();
        return Constructs.Statements.clearCache();
      };
      return Constructs;
    }
  ]);

}).call(this);
