(function() {
  var topics;

  topics = angular.module('archivist.data_manager.topics', ['archivist.resource']);

  topics.factory('Topics', [
    'WrappedResource', function(WrappedResource) {
      var wr;
      wr = new WrappedResource('topics/:id.json', {
        id: '@id'
      }, {
        getNested: {
          method: 'GET',
          url: '/topics/nested_index.json',
          isArray: true
        },
        getFlattenedNest: {
          method: 'GET',
          url: '/topics/flattened_nest.json',
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
      });
      wr.questionStatistics = function(parameters, success, error) {
        return wr.resource.questionStatistics(parameters, success, error);
      };
      wr.variableStatistics = function(parameters, success, error) {
        return wr.resource.variableStatistics(parameters, success, error);
      };
      wr.getNested = function(parameters, success, error) {
        if (wr.data['getNested'] == null) {
          wr.data['getNested'] = wr.resource.getNested(parameters, success, error);
        }
        return wr.data['getNested'];
      };
      wr.regetNested = function(parameters, success, error) {
        wr.data['getNested'] = null;
        return wr.getNested(parameters, success, error);
      };
      wr.getFlattenedNest = function(parameters, success, error) {
        if (wr.data['getFlattenedNest'] == null) {
          wr.data['getFlattenedNest'] = wr.resource.getFlattenedNest(parameters, success, error);
        }
        return wr.data['getFlattenedNest'];
      };
      wr.regetFlattenedNest = function(parameters, success, error) {
        wr.data['getFlattenedNest'] = null;
        return wr.getFlattenedNest(parameters, success, error);
      };
      return wr;
    }
  ]);

}).call(this);
