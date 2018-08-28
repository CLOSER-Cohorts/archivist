(function() {
  var instruments;

  instruments = angular.module('archivist.data_manager.instruments', ['archivist.resource']);

  instruments.factory('Instruments', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:id.json', {
        id: '@id'
      }, {
        save: {
          method: 'PUT'
        },
        create: {
          method: 'POST'
        },
        copy: {
          method: 'POST',
          url: 'instruments/:id/copy/:prefix.json'
        },
        clear_cache: {
          method: 'GET',
          url: 'instruments/:id/clear_cache.json'
        }
      });
    }
  ]);

  instruments.factory('InstrumentRelationshipResolver', [
    function() {
      return function(instruments, reference) {
        switch (reference.type) {
          case "CcCondition":
            return instruments.conditions.select_resource_by_id(reference.id);
          case "CcLoop":
            return instruments.loops.select_resource_by_id(reference.id);
          case "CcQuestion":
            return instruments.questions.select_resource_by_id(reference.id);
          case "CcSequence":
            return instruments.sequences.select_resource_by_id(reference.id);
          case "CcStatement":
            return instruments.statements.select_resource_by_id(reference.id);
        }
      };
    }
  ]);

}).call(this);
