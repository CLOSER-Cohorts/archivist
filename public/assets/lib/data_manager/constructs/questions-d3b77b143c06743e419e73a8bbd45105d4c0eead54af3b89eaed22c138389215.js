(function() {
  var questions;

  questions = angular.module('archivist.data_manager.constructs.questions', ['archivist.resource']);

  questions.factory('Questions', [
    'WrappedResource', function(WrappedResource) {
      return {
        cc: new WrappedResource('instruments/:instrument_id/cc_questions/:id.json', {
          id: '@id',
          instrument_id: '@instrument_id'
        }, {
          save: {
            method: 'PUT'
          },
          create: {
            method: 'POST'
          },
          update_topic: {
            method: 'POST',
            url: 'instruments/:instrument_id/cc_questions/:id/set_topic.json'
          },
          split_mapping: {
            method: 'POST',
            url: 'instruments/:instrument_id/cc_questions/:id/remove_variable.json'
          },
          add_mapping: {
            method: 'POST',
            url: 'instruments/:instrument_id/cc_questions/:id/add_variables.json'
          }
        }),
        item: new WrappedResource('instruments/:instrument_id/question_items/:id.json', {
          id: '@id',
          instrument_id: '@instrument_id'
        }),
        grid: new WrappedResource('instruments/:instrument_id/question_grids/:id.json', {
          id: '@id',
          instrument_id: '@instrument_id'
        }),
        clearCache: function() {
          if (typeof cc !== "undefined" && cc !== null) {
            cc.clearCache();
          }
          if (typeof item !== "undefined" && item !== null) {
            item.clearCache();
          }
          if (typeof grid !== "undefined" && grid !== null) {
            return grid.clearCache();
          }
        }
      };
    }
  ]);

}).call(this);
