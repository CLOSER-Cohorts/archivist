(function() {
  var data_manager;

  data_manager = angular.module('archivist.data_manager', ['archivist.data_manager.map', 'archivist.data_manager.instruments', 'archivist.data_manager.constructs', 'archivist.data_manager.codes', 'archivist.data_manager.response_units', 'archivist.data_manager.response_domains', 'archivist.data_manager.datasets', 'archivist.data_manager.variables', 'archivist.data_manager.variables_instrument', 'archivist.data_manager.resolution', 'archivist.data_manager.stats', 'archivist.data_manager.topics', 'archivist.data_manager.auth', 'archivist.resource']);

  data_manager.factory('DataManager', [
    '$http', '$q', 'Map', 'Instruments', 'Constructs', 'Codes', 'ResponseUnits', 'ResponseDomains', 'ResolutionService', 'GetResource', 'ApplicationStats', 'Topics', 'InstrumentStats', 'Datasets', 'Variables', 'VariablesInstrument', 'Auth', function($http, $q, Map, Instruments, Constructs, Codes, ResponseUnits, ResponseDomains, ResolutionService, GetResource, ApplicationStats, Topics, InstrumentStats, Datasets, Variables, VariablesInstrument, Auth) {
      var DataManager;
      DataManager = {};
      DataManager.Data = {};
      DataManager.Instruments = Instruments;
      DataManager.Constructs = Constructs;
      DataManager.Codes = Codes;
      DataManager.ResponseUnits = ResponseUnits;
      DataManager.ResponseDomains = ResponseDomains;
      DataManager.Datasets = Datasets;
      DataManager.Variables = Variables;
      DataManager.VariablesInstrument = VariablesInstrument;
      DataManager.Auth = Auth;
      DataManager.clearCache = function() {
        DataManager.Data = {};
        DataManager.Data.ResponseDomains = {};
        DataManager.Data.ResponseUnits = {};
        DataManager.Data.InstrumentStats = {};
        DataManager.Data.Users = {};
        DataManager.Data.Groups = {};
        DataManager.Data.Clusters = {};
        DataManager.Instruments.clearCache();
        DataManager.Constructs.clearCache();
        DataManager.Codes.clearCache();
        DataManager.ResponseUnits.clearCache();
        DataManager.Datasets.clearCache();
        DataManager.Variables.clearCache();
        DataManager.VariablesInstrument.clearCache();
        return DataManager.Auth.clearCache();
      };
      DataManager.clearCache();
      DataManager.getInstruments = function(params, success, error) {
        DataManager.Data.Instruments = DataManager.Instruments.query(params, success, error);
        return DataManager.Data.Instruments;
      };
      DataManager.getDatasets = function(params, success, error) {
        DataManager.Data.Datasets = DataManager.Datasets.query(params, success, error);
        return DataManager.Data.Datasets;
      };
      DataManager.getInstrument = function(instrument_id, options, success, error) {
        var base, base1, base2, chunk_size, i, len, promise, promises;
        if (options == null) {
          options = {};
        }
        console.log('getInstrument');
        DataManager.progress = 0;
        if (options.codes == null) {
          options.codes = false;
        }
        if (options.constructs == null) {
          options.constructs = false;
        }
        if (options.questions == null) {
          options.questions = false;
        }
        if (options.rds == null) {
          options.rds = false;
        }
        if (options.rus == null) {
          options.rus = false;
        }
        if (options.instrument == null) {
          options.instrument = true;
        }
        if (options.topsequence == null) {
          options.topsequence = true;
        }
        if (options.variables == null) {
          options.variables = false;
        }
        promises = [];
        DataManager.Data.Instrument = DataManager.Instruments.get({
          id: instrument_id
        });
        promises.push(DataManager.Data.Instrument.$promise);
        if (options.codes) {
          if ((base = DataManager.Data).Codes == null) {
            base.Codes = {};
          }
          DataManager.Data.Codes.CodeLists = DataManager.Codes.CodeLists.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.Codes.CodeLists.$promise);
          DataManager.Data.Codes.Categories = DataManager.Codes.Categories.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.Codes.Categories.$promise);
        }
        if (options.constructs) {
          if ((base1 = DataManager.Data).Constructs == null) {
            base1.Constructs = {};
          }
          if (options.constructs === true || options.constructs.conditions) {
            DataManager.Data.Constructs.Conditions = DataManager.Constructs.Conditions.query({
              instrument_id: instrument_id
            });
            promises.push(DataManager.Data.Constructs.Conditions.$promise.then(function(collection) {
              var i, index, len, obj, results;
              results = [];
              for (index = i = 0, len = collection.length; i < len; index = ++i) {
                obj = collection[index];
                results.push(collection[index].type = 'condition');
              }
              return results;
            }));
          }
          if (options.constructs === true || options.constructs.loops) {
            DataManager.Data.Constructs.Loops = DataManager.Constructs.Loops.query({
              instrument_id: instrument_id
            });
            promises.push(DataManager.Data.Constructs.Loops.$promise.then(function(collection) {
              var i, index, len, obj, results;
              results = [];
              for (index = i = 0, len = collection.length; i < len; index = ++i) {
                obj = collection[index];
                results.push(collection[index].type = 'loop');
              }
              return results;
            }));
          }
          if (options.constructs === true || options.constructs.questions) {
            DataManager.Data.Constructs.Questions = DataManager.Constructs.Questions.cc.query({
              instrument_id: instrument_id
            });
            promises.push(DataManager.Data.Constructs.Questions.$promise.then(function(collection) {
              var i, index, len, obj, results;
              results = [];
              for (index = i = 0, len = collection.length; i < len; index = ++i) {
                obj = collection[index];
                results.push(collection[index].type = 'question');
              }
              return results;
            }));
          }
          if (options.constructs === true || options.constructs.statements) {
            DataManager.Data.Constructs.Statements = DataManager.Constructs.Statements.query({
              instrument_id: instrument_id
            });
            promises.push(DataManager.Data.Constructs.Statements.$promise.then(function(collection) {
              var i, index, len, obj, results;
              results = [];
              for (index = i = 0, len = collection.length; i < len; index = ++i) {
                obj = collection[index];
                results.push(collection[index].type = 'statement');
              }
              return results;
            }));
          }
          if (options.constructs === true || options.constructs.sequences) {
            DataManager.Data.Constructs.Sequences = DataManager.Constructs.Sequences.query({
              instrument_id: instrument_id
            });
            promises.push(DataManager.Data.Constructs.Sequences.$promise.then(function(collection) {
              var i, index, len, obj, results;
              console.log('sequence altering');
              results = [];
              for (index = i = 0, len = collection.length; i < len; index = ++i) {
                obj = collection[index];
                results.push(collection[index].type = 'sequence');
              }
              return results;
            }));
            if (options.instrument) {
              if (typeof DataManager.Data.Instrument.Constructs === 'undefined') {
                DataManager.Data.Instrument.Constructs = {};
              }
              DataManager.Data.Instrument.Constructs.Sequences = DataManager.Data.Constructs.Sequences;
              true;
            }
          }
        }
        if (options.questions) {
          if ((base2 = DataManager.Data).Questions == null) {
            base2.Questions = {};
          }
          DataManager.Data.Questions.Items = DataManager.Constructs.Questions.item.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.Questions.Items.$promise);
          DataManager.Data.Questions.Grids = DataManager.Constructs.Questions.grid.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.Questions.Grids.$promise);
        }
        if (options.rds) {
          DataManager.Data.ResponseDomains = {};
          DataManager.Data.ResponseDomains.Codes = DataManager.ResponseDomains.Codes.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.ResponseDomains.Codes.$promise);
          DataManager.Data.ResponseDomains.Datetimes = DataManager.ResponseDomains.Datetimes.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.ResponseDomains.Datetimes.$promise);
          DataManager.Data.ResponseDomains.Numerics = DataManager.ResponseDomains.Numerics.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.ResponseDomains.Numerics.$promise);
          DataManager.Data.ResponseDomains.Texts = DataManager.ResponseDomains.Texts.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.ResponseDomains.Texts.$promise);
        }
        if (options.rus) {
          DataManager.Data.ResponseUnits = DataManager.ResponseUnits.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.ResponseUnits.$promise);
        }
        if (options.variables) {
          DataManager.Data.Variables = DataManager.VariablesInstrument.query({
            instrument_id: instrument_id
          });
          promises.push(DataManager.Data.Variables.$promise);
        }
        chunk_size = 100 / promises.length;
        for (i = 0, len = promises.length; i < len; i++) {
          promise = promises[i];
          promise["finally"](function() {
            DataManager.progress += chunk_size;
            if (options.progress != null) {
              return options.progress(DataManager.progress);
            }
          });
        }
        $q.all(promises).then(function() {
          var base3, s;
          console.log('All promises resolved');
          if (options.instrument) {
            if (options.constructs) {
              DataManager.Data.Instrument.Constructs = {};
              DataManager.Data.Instrument.Constructs.Conditions = DataManager.Data.Constructs.Conditions;
              DataManager.Data.Instrument.Constructs.Loops = DataManager.Data.Constructs.Loops;
              DataManager.Data.Instrument.Constructs.Questions = DataManager.Data.Constructs.Questions;
              DataManager.Data.Instrument.Constructs.Sequences = DataManager.Data.Constructs.Sequences;
              DataManager.Data.Instrument.Constructs.Statements = DataManager.Data.Constructs.Statements;
            }
            if (options.questions) {
              if ((base3 = DataManager.Data.Instrument).Questions == null) {
                base3.Questions = {};
              }
              DataManager.Data.Instrument.Questions.Items = DataManager.Data.Questions.Items;
              DataManager.Data.Instrument.Questions.Grids = DataManager.Data.Questions.Grids;
            }
            if (options.codes) {
              DataManager.Data.Instrument.CodeLists = DataManager.Data.Codes.CodeLists;
            }
            if (options.rds) {
              DataManager.groupResponseDomains();
            }
            if (options.rus) {
              DataManager.Data.Instrument.ResponseUnits = DataManager.Data.ResponseUnits;
            }
            if (options.variables) {
              DataManager.Data.Instrument.Variables = DataManager.Data.Variables;
            }
          }
          console.log('callbacks called');
          if (options.constructs && options.instrument && options.topsequence) {
            DataManager.Data.Instrument.topsequence = ((function() {
              var j, len1, ref, results;
              ref = DataManager.Data.Instrument.Constructs.Sequences;
              results = [];
              for (j = 0, len1 = ref.length; j < len1; j++) {
                s = ref[j];
                if (s.top) {
                  results.push(s);
                }
              }
              return results;
            })())[0];
          }
          return typeof success === "function" ? success() : void 0;
        });
        return DataManager.Data.Instrument;
      };
      DataManager.getDataset = function(dataset_id, options, success, error) {
        var promises;
        if (options == null) {
          options = {};
        }
        if (options.variables == null) {
          options.variables = false;
        }
        if (options.questions == null) {
          options.questions = false;
        }
        promises = [];
        DataManager.Data.Dataset = DataManager.Datasets.get({
          id: dataset_id,
          questions: options.questions
        });
        promises.push(DataManager.Data.Dataset.$promise);
        if (options.variables) {
          DataManager.Data.Variables = DataManager.Variables.query({
            dataset_id: dataset_id
          });
          promises.push(DataManager.Data.Variables.$promise);
        }
        $q.all(promises).then(function() {
          if (options.variables) {
            DataManager.Data.Dataset.Variables = DataManager.Data.Variables;
          }
          return typeof success === "function" ? success() : void 0;
        });
        return DataManager.Data.Dataset;
      };
      DataManager.groupResponseDomains = function() {
        return DataManager.Data.Instrument.ResponseDomains = DataManager.Data.ResponseDomains.Datetimes.concat(DataManager.Data.ResponseDomains.Numerics, DataManager.Data.ResponseDomains.Texts, DataManager.Data.ResponseDomains.Codes);
      };
      DataManager.getResponseUnits = function(instrument_id, force, cb) {
        if (force == null) {
          force = false;
        }
        if ((DataManager.Data.ResponseUnits[instrument_id] == null) || force) {
          return DataManager.Data.ResponseUnits[instrument_id] = GetResource('/instruments/' + instrument_id + '/response_units.json', true, cb);
        } else {
          return typeof cb === "function" ? cb() : void 0;
        }
      };
      DataManager.getCluster = function(type, id, force, cb) {
        var index;
        if (force == null) {
          force = false;
        }
        index = type + '/' + id;
        if ((DataManager.Data.Clusters[index] == null) || force) {
          DataManager.Data.Clusters[index] = GetResource('/clusters/' + index + '.json', true, cb);
        } else {
          if (typeof cb === "function") {
            cb();
          }
        }
        return DataManager.Data.Clusters[index];
      };
      DataManager.resolveConstructs = function(options) {
        if (DataManager.ConstructResolver == null) {
          DataManager.ConstructResolver = new ResolutionService.ConstructResolver(DataManager.Data.Constructs);
        }
        return DataManager.ConstructResolver.broken_resolve();
      };
      DataManager.resolveQuestions = function() {
        if (DataManager.QuestionResolver == null) {
          DataManager.QuestionResolver = new ResolutionService.QuestionResolver(DataManager.Data.Questions);
        }
        return DataManager.QuestionResolver.resolve(DataManager.Data.Constructs.Questions);
      };
      DataManager.resolveCodes = function() {
        if (DataManager.CodeResolver == null) {
          DataManager.CodeResolver = new ResolutionService.CodeResolver(DataManager.Data.Codes.CodeLists, DataManager.Data.Codes.Categories);
        }
        return DataManager.CodeResolver.resolve();
      };
      DataManager.getApplicationStats = function() {
        DataManager.Data.AppStats = {
          $resolved: false
        };
        DataManager.Data.AppStats.$promise = ApplicationStats;
        DataManager.Data.AppStats.$promise.then(function(res) {
          var key;
          for (key in res.data) {
            if (res.data.hasOwnProperty(key)) {
              DataManager.Data.AppStats[key] = res.data[key];
            }
          }
          return DataManager.Data.AppStats.$resolved = true;
        });
        return DataManager.Data.AppStats;
      };
      DataManager.getTopics = function(options) {
        if (options == null) {
          options = {};
        }
        if (options.nested == null) {
          options.nested = false;
        }
        if (options.flattened == null) {
          options.flattened = false;
        }
        if (options.nested) {
          DataManager.Data.Topics = Topics.getNested();
        }
        if (options.flattened) {
          DataManager.Data.Topics = Topics.getFlattenedNest();
        }
        return DataManager.Data.Topics;
      };
      DataManager.updateTopic = function(model, topic_id) {
        console.log(model);
        delete model.topic;
        delete model.strand;
        delete model.suggested_topic;
        return model.$update_topic({
          topic_id: Number.isInteger(topic_id) ? topic_id : null
        });
      };
      DataManager.getInstrumentStats = function(id, cb) {
        DataManager.Data.InstrumentStats[id] = {
          $resolved: false
        };
        DataManager.Data.InstrumentStats[id].$promise = InstrumentStats(id);
        DataManager.Data.InstrumentStats[id].$promise.then(function(res) {
          var key;
          for (key in res.data) {
            if (res.data.hasOwnProperty(key)) {
              DataManager.Data.InstrumentStats[id][key] = res.data[key];
            }
          }
          DataManager.Data.InstrumentStats[id].$resolved = true;
          if (cb != null) {
            return cb.call();
          }
        });
        return DataManager.Data.InstrumentStats[id];
      };
      DataManager.getQuestionItemIDs = function() {
        var i, len, output, qi, ref;
        output = [];
        ref = DataManager.Data.Questions.Items;
        for (i = 0, len = ref.length; i < len; i++) {
          qi = ref[i];
          output.push({
            value: qi.id,
            label: qi.label,
            type: 'QuestionItem'
          });
        }
        return output;
      };
      DataManager.getQuestionGridIDs = function() {
        var i, len, output, qg, ref;
        output = [];
        ref = DataManager.Data.Questions.Grids;
        for (i = 0, len = ref.length; i < len; i++) {
          qg = ref[i];
          output.push({
            value: qg.id,
            label: qg.label,
            type: 'QuestionGrid'
          });
        }
        return output;
      };
      DataManager.getQuestionIDs = function() {
        return DataManager.getQuestionItemIDs().concat(DataManager.getQuestionGridIDs());
      };
      DataManager.getUsers = function() {
        var promises;
        promises = [];
        DataManager.Data.Users = DataManager.Auth.Users.query();
        promises.push(DataManager.Data.Users.$promise);
        DataManager.Data.Groups = DataManager.Auth.Groups.query();
        promises.push(DataManager.Data.Groups.$promise);
        return $q.all(promises).then(function() {
          if (DataManager.GroupResolver == null) {
            DataManager.GroupResolver = new ResolutionService.GroupResolver(DataManager.Data.Groups, DataManager.Data.Users);
          }
          return DataManager.GroupResolver.resolve();
        });
      };
      return DataManager;
    }
  ]);

}).call(this);
(function() {
  var auth;

  auth = angular.module('archivist.data_manager.auth', ['archivist.data_manager.auth.groups', 'archivist.data_manager.auth.users']);

  auth.factory('Auth', [
    'Groups', 'Users', function(Groups, Users) {
      var Auth;
      Auth = {};
      Auth.Groups = Groups;
      Auth.Users = Users;
      Auth.clearCache = function() {
        Auth.Groups.clearCache();
        return Auth.Users.clearCache();
      };
      return Auth;
    }
  ]);

}).call(this);
(function() {
  var groups;

  groups = angular.module('archivist.data_manager.auth.groups', ['archivist.resource']);

  groups.factory('Groups', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('user_groups/:id.json', {
        id: '@id'
      });
    }
  ]);

}).call(this);
(function() {
  var users;

  users = angular.module('archivist.data_manager.auth.users', ['archivist.resource']);

  users.factory('Users', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('users/admin/:id.json', {
        id: '@id'
      }, {
        save: {
          method: 'PUT'
        },
        create: {
          method: 'POST'
        },
        "delete": {
          method: 'DELETE',
          url: 'users/admin/:id.json'
        },
        reset_password: {
          method: 'POST',
          url: 'users/admin/:id/password.json'
        },
        lock: {
          method: 'POST',
          url: 'users/admin/:id/lock.json'
        }
      });
    }
  ]);

}).call(this);
(function() {
  var codes;

  codes = angular.module('archivist.data_manager.codes', ['archivist.data_manager.codes.code_lists', 'archivist.data_manager.codes.categories']);

  codes.factory('Codes', [
    'CodeLists', 'Categories', 'CodeResolver', function(CodeLists, Categories, CodeResolver) {
      var Codes;
      Codes = {};
      Codes.CodeLists = CodeLists;
      Codes.Categories = Categories;
      Codes.CodeResolver = CodeResolver;
      Codes.clearCache = function() {
        Codes.CodeLists.clearCache();
        return Codes.Categories.clearCache();
      };
      return Codes;
    }
  ]);

  codes.factory('CodeResolver', [
    function() {
      return {
        code_list: function(scope, code) {
          return scope.code_lists.select_resource_by_id(code.code_list_id);
        },
        category: function(scope, code) {
          return scope.categories.select_resource_by_id(code.category_id);
        },
        code_lists: function(scope, category) {
          var code, i, len, ref, results;
          ref = scope.codes;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            code = ref[i];
            if (code.category_id === category.id) {
              results.push(this.code_list(scope, code));
            }
          }
          return results;
        },
        categories: function(scope, code_list) {
          var code, i, len, ref, results;
          ref = code_list.codes;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            code = ref[i];
            results.push(code.label = this.category(scope, code)['label']);
          }
          return results;
        }
      };
    }
  ]);

}).call(this);
(function() {
  var categories;

  categories = angular.module('archivist.data_manager.codes.categories', ['archivist.resource']);

  categories.factory('Categories', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/categories/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
(function() {
  var code_lists;

  code_lists = angular.module('archivist.data_manager.codes.code_lists', ['archivist.resource']);

  code_lists.factory('CodeLists', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/code_lists/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
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
(function() {
  var conditions;

  conditions = angular.module('archivist.data_manager.constructs.conditions', ['archivist.resource']);

  conditions.factory('Conditions', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/cc_conditions/:id.json', {
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
          url: 'instruments/:instrument_id/cc_conditions/:id/set_topic.json'
        }
      });
    }
  ]);

}).call(this);
(function() {
  var loops;

  loops = angular.module('archivist.data_manager.constructs.loops', ['ngResource']);

  loops.factory('Loops', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/cc_loops/:id.json', {
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
          url: 'instruments/:instrument_id/cc_loops/:id/set_topic.json'
        }
      });
    }
  ]);

}).call(this);
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
(function() {
  var sequences;

  sequences = angular.module('archivist.data_manager.constructs.sequences', ['ngResource']);

  sequences.factory('Sequences', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/cc_sequences/:id.json', {
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
          url: 'instruments/:instrument_id/cc_sequences/:id/set_topic.json'
        }
      });
    }
  ]);

}).call(this);
(function() {
  var statements;

  statements = angular.module('archivist.data_manager.constructs.statements', ['ngResource']);

  statements.factory('Statements', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/cc_statements/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
(function() {
  var datasets;

  datasets = angular.module('archivist.data_manager.datasets', ['archivist.resource']);

  datasets.factory('Datasets', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('datasets/:id.json', {
        id: '@id'
      }, {
        save: {
          method: 'PUT'
        },
        create: {
          method: 'POST'
        }
      });
    }
  ]);

}).call(this);
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
(function() {
  var map;

  map = angular.module('archivist.data_manager.map', []);

  map.factory('Map', [
    function() {
      var service;
      service = {};
      service.map = {
        Instrument: 'Instruments',
        CcCondition: {
          Constructs: 'Conditions'
        },
        CcLoop: {
          Constructs: 'Loops'
        },
        CcQuestion: {
          Constructs: 'Questions'
        },
        CcSequence: {
          Constructs: 'Sequences'
        },
        CcStatement: {
          Constructs: 'Statements'
        },
        QuestionItem: {
          Questions: 'Items'
        },
        QuestionGrid: {
          Questions: 'Grids'
        },
        ResponseDomainText: {
          ResponseDomains: 'Texts'
        },
        ResponseDomainNumeric: {
          ResponseDomains: 'Numerics'
        },
        ResponseDomainDatetime: {
          ResponseDomains: 'Datetimes'
        },
        Variable: 'Variables'
      };
      service.find = function(obj, ident) {
        var dig;
        dig = function(obj, lookup) {
          var k, output, v;
          output = obj;
          if (typeof lookup === "object") {
            for (k in lookup) {
              v = lookup[k];
              if (lookup.hasOwnProperty(k)) {
                output = dig(output[k], v);
              }
            }
          } else {
            output = output[lookup];
          }
          return output;
        };
        return dig(obj, service.map[ident]);
      };
      service.translate = function(ident) {
        var dig;
        dig = function(lookup) {
          if (typeof lookup === "object") {
            return dig(lookup[Object.keys(lookup)[0]]);
          } else {
            return lookup;
          }
        };
        return dig(service.map[ident]);
      };
      return service;
    }
  ]);

}).call(this);
(function() {
  var resolution,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  resolution = angular.module('archivist.data_manager.resolution', []);

  resolution.factory('ResolutionService', [
    '$timeout', '$rootScope', function($timeout, $rootScope) {
      var service;
      service = {};
      service.ConstructResolver = (function() {
        function _Class(constructs) {
          this.constructs = constructs;
        }

        _Class.prototype.map = {
          CcCondition: 'Conditions',
          CcLoop: 'Loops',
          CcQuestion: 'Questions',
          CcSequence: 'Sequences',
          CcStatement: 'Statements'
        };

        _Class.prototype.queue = [];

        _Class.prototype.added_to_queue = 0;

        _Class.prototype.resolve_children = function(item) {
          var child, i, index, j, len, len1, ref, ref1, self;
          console.log(item.children);
          ref = item.children.slice().reverse();
          for (index = i = 0, len = ref.length; i < len; index = ++i) {
            child = ref[index];
            if (child.type != null) {
              if (child.type in this.map) {
                item.children[item.children.length - 1 - index] = this.constructs[this.map[child.type]].select_resource_by_id(child.id);
              }
            }
            if (item.children[item.children.length - 1 - index].children != null) {
              this.queue.unshift(item.children[item.children.length - 1 - index]);
              this.added_to_queue = this.added_to_queue + 1;
            }
          }
          if (item.fchildren != null) {
            ref1 = item.fchildren.slice().reverse();
            for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
              child = ref1[index];
              if (child.type != null) {
                if (child.type in this.map) {
                  item.fchildren[item.fchildren.length - 1 - index] = this.constructs[this.map[child.type]].select_resource_by_id(child.id);
                }
              }
              if (item.fchildren[item.fchildren.length - 1 - index].children != null) {
                this.queue.unshift(item.fchildren[item.fchildren.length - 1 - index]);
                this.added_to_queue = this.added_to_queue + 1;
              }
            }
          }
          item.resolved = true;
          self = this;
          if (this.queue.length > 0) {
            console.log('Scheduled resolution');
            return $timeout(function(item) {
              index = 'resolving:' + item.label;
              console.time(index);
              self.resolve_children(item);
              return console.timeEnd(index);
            }, 0, false, self.queue.shift());
          } else {
            console.log('call digest');
            return $rootScope.$digest();
          }
        };

        _Class.prototype.broken_resolve = function() {
          var self, seq;
          self = this;
          this.queue.unshift(((function() {
            var i, len, ref, results;
            ref = this.constructs.Sequences;
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
              seq = ref[i];
              if (seq.top) {
                results.push(seq);
              }
            }
            return results;
          }).call(this))[0]);
          this.added_to_queue = this.added_to_queue + 1;
          return $timeout(function() {
            return self.resolve_children(self.queue.shift());
          }, 0);
        };

        _Class.prototype.resolve = function(to_check, check_against) {
          var child, collection, construct, index, key, ref, results;
          if (to_check == null) {
            to_check = ['Conditions', 'Loops', 'Sequences'];
          }
          if (check_against == null) {
            check_against = ['Conditions', 'Loops', 'Questions', 'Sequences', 'Statements'];
          }
          ref = this.constructs;
          results = [];
          for (key in ref) {
            collection = ref[key];
            if (indexOf.call(to_check, key) >= 0) {
              results.push((function() {
                var i, j, k, len, len1, len2, ref1, ref2, results1;
                results1 = [];
                for (i = 0, len = collection.length; i < len; i++) {
                  construct = collection[i];
                  ref1 = construct.children;
                  for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
                    child = ref1[index];
                    if (child.type != null) {
                      if (child.type in this.map) {
                        construct.children[index] = this.constructs[this.map[child.type]].select_resource_by_id(child.id);
                      }
                    }
                  }
                  if (construct.fchildren != null) {
                    ref2 = construct.fchildren;
                    for (index = k = 0, len2 = ref2.length; k < len2; index = ++k) {
                      child = ref2[index];
                      if (child.type != null) {
                        if (child.type in this.map) {
                          construct.fchildren[index] = this.constructs[this.map[child.type]].select_resource_by_id(child.id);
                        }
                      }
                    }
                  }
                  results1.push(construct.resolved = true);
                }
                return results1;
              }).call(this));
            } else {
              results.push(void 0);
            }
          }
          return results;
        };

        return _Class;

      })();
      service.QuestionResolver = (function() {
        function _Class(questions) {
          this.questions = questions;
        }

        _Class.prototype.map = {
          QuestionItem: 'Items',
          QuestionGrid: 'Grids'
        };

        _Class.prototype.resolve = function(constructs) {
          var base, construct, i, index, len, results;
          results = [];
          for (index = i = 0, len = constructs.length; i < len; index = ++i) {
            construct = constructs[index];
            results.push((base = constructs[index]).base != null ? base.base : base.base = this.questions[this.map[construct.question_type]].select_resource_by_id(construct.question_id));
          }
          return results;
        };

        return _Class;

      })();
      service.CodeResolver = (function() {
        function _Class(codes_lists, categories) {
          this.code_lists = codes_lists;
          this.categories = categories;
        }

        _Class.prototype.category = function(code) {
          return this.categories.select_resource_by_id(code.category_id);
        };

        _Class.prototype.resolve = function() {
          var code, code_list, i, index, len, ref, results;
          ref = this.code_lists;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            code_list = ref[i];
            results.push((function() {
              var j, len1, ref1, results1;
              ref1 = code_list.codes;
              results1 = [];
              for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
                code = ref1[index];
                results1.push(code_list.codes[index].label = this.category(code)['label']);
              }
              return results1;
            }).call(this));
          }
          return results;
        };

        return _Class;

      })();
      service.GroupResolver = (function() {
        function _Class(groups, users) {
          this.groups = groups;
          this.users = users;
        }

        _Class.prototype.resolve = function() {
          var group, group_index, i, len, ref, results, user, user_index;
          ref = this.groups;
          results = [];
          for (group_index = i = 0, len = ref.length; i < len; group_index = ++i) {
            group = ref[group_index];
            this.groups[group_index].users = [];
            results.push((function() {
              var j, len1, ref1, results1;
              ref1 = this.users;
              results1 = [];
              for (user_index = j = 0, len1 = ref1.length; j < len1; user_index = ++j) {
                user = ref1[user_index];
                if (group.id === user.group_id) {
                  this.users[user_index].group = group.label;
                  results1.push(this.groups[group_index].users.push(user));
                } else {
                  results1.push(void 0);
                }
              }
              return results1;
            }).call(this));
          }
          return results;
        };

        return _Class;

      })();
      return service;
    }
  ]);

}).call(this);
(function() {
  var rds;

  rds = angular.module('archivist.data_manager.response_domains', ['archivist.data_manager.response_domains.codes', 'archivist.data_manager.response_domains.datetimes', 'archivist.data_manager.response_domains.numerics', 'archivist.data_manager.response_domains.texts']);

  rds.factory('ResponseDomains', [
    'ResponseDomainDatetimes', 'ResponseDomainNumerics', 'ResponseDomainTexts', 'ResponseDomainCodes', function(ResponseDomainDatetimes, ResponseDomainNumerics, ResponseDomainTexts, ResponseDomainCodes) {
      var ResponseDomains;
      ResponseDomains = {};
      ResponseDomains.Datetimes = ResponseDomainDatetimes;
      ResponseDomains.Numerics = ResponseDomainNumerics;
      ResponseDomains.Texts = ResponseDomainTexts;
      ResponseDomains.Codes = ResponseDomainCodes;
      ResponseDomains.clearCache = function() {
        ResponseDomains.Datetimes.clearCache();
        ResponseDomains.Numerics.clearCache();
        ResponseDomains.Texts.clearCache();
        return ResponseDomains.Codes.clearCache();
      };
      return ResponseDomains;
    }
  ]);

}).call(this);
(function() {
  var codes;

  codes = angular.module('archivist.data_manager.response_domains.codes', ['archivist.resource']);

  codes.factory('ResponseDomainCodes', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/response_domain_codes/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
(function() {
  var datetimes;

  datetimes = angular.module('archivist.data_manager.response_domains.datetimes', ['archivist.resource']);

  datetimes.factory('ResponseDomainDatetimes', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/response_domain_datetimes/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
(function() {
  var numerics;

  numerics = angular.module('archivist.data_manager.response_domains.numerics', ['archivist.resource']);

  numerics.factory('ResponseDomainNumerics', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/response_domain_numerics/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
(function() {
  var texts;

  texts = angular.module('archivist.data_manager.response_domains.texts', ['archivist.resource']);

  texts.factory('ResponseDomainTexts', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/response_domain_texts/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
(function() {
  var conditions;

  conditions = angular.module('archivist.data_manager.response_units', ['archivist.resource']);

  conditions.factory('ResponseUnits', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/response_units/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
(function() {
  var stats;

  stats = angular.module('archivist.data_manager.stats', []);

  stats.factory('ApplicationStats', [
    '$http', function($http) {
      return $http.get('/stats.json', {
        cache: true
      });
    }
  ]);

  stats.factory('InstrumentStats', [
    '$http', function($http) {
      return function(id) {
        return $http.get('/instruments/' + id + '/stats.json', {
          cache: true
        });
      };
    }
  ]);

}).call(this);
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
(function() {
  var variables;

  variables = angular.module('archivist.data_manager.variables', ['archivist.resource']);

  variables.factory('Variables', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('datasets/:dataset_id/variables/:id.json', {
        id: '@id',
        dataset_id: '@dataset_id'
      }, {
        save: {
          method: 'PUT'
        },
        create: {
          method: 'POST'
        },
        update_topic: {
          method: 'POST',
          url: 'datasets/:dataset_id/variables/:id/set_topic.json'
        },
        split_mapping: {
          method: 'POST',
          url: 'datasets/:dataset_id/variables/:id/remove_source.json'
        },
        add_mapping: {
          method: 'POST',
          url: 'datasets/:dataset_id/variables/:id/add_sources.json'
        }
      });
    }
  ]);

}).call(this);
(function() {
  var variablesInstrument;

  variablesInstrument = angular.module('archivist.data_manager.variables_instrument', ['archivist.resource']);

  variablesInstrument.factory('VariablesInstrument', [
    'WrappedResource', function(WrappedResource) {
      return new WrappedResource('instruments/:instrument_id/variables/:id.json', {
        id: '@id',
        instrument_id: '@instrument_id'
      });
    }
  ]);

}).call(this);
(function() {
  var flash;

  flash = angular.module('archivist.flash', ['ngMessages']);

  flash.factory('Flash', [
    '$interval', function($interval) {
      var LOCAL_STORAGE_KEY, clear, notices, scope, store;
      LOCAL_STORAGE_KEY = 'notices';
      notices = JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY)) || [];
      scope = null;
      store = function() {
        return localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(notices));
      };
      clear = function() {
        notices = [];
        return store();
      };
      return {
        add: function(type, message) {
          notices.push({
            type: type,
            message: message
          });
          store();
          if (document.getElementsByTagName(LOCAL_STORAGE_KEY)) {
            return this.publish(scope);
          }
        },
        publish: function(_scope) {
          _scope.notices = notices;
          return clear();
        },
        set_scope: function(_scope) {
          return scope = _scope;
        },
        listen: function(scope) {},
        clear: this.clear,
        store: this.store
      };
    }
  ]);

}).call(this);
(function() {
  var resource;

  resource = angular.module('archivist.resource', ['ngResource']);

  resource.factory('WrappedResource', [
    '$resource', function($resource) {
      return function(path, paramDefaults, actions, options) {
        var that;
        that = this;
        this.data = {};
        if (actions != null) {
          this.actions = actions;
        } else {
          this.actions = {
            save: {
              method: 'PUT'
            },
            create: {
              method: 'POST'
            }
          };
        }
        this.index = function(method, parameters) {
          return path + method + JSON.stringify(parameters);
        };
        this.resource = $resource(path, paramDefaults, this.actions, options);
        this.resource.prototype.save = function(params, success, error) {
          console.trace();
          if (this.id != null) {
            return this.$save(params, success, error);
          } else {
            return this.$create(params, success, error);
          }
        };
        this.query = function(parameters, success, error) {
          if (that.data[this.index('query', parameters)] == null) {
            that.data[this.index('query', parameters)] = that.resource.query(parameters, function(value, responseHeaders) {
              var i, k, len, obj, v;
              for (i = 0, len = value.length; i < len; i++) {
                obj = value[i];
                for (k in parameters) {
                  v = parameters[k];
                  obj[k] = v;
                }
              }
              if (success != null) {
                return success(value, responseHeaders);
              }
            }, error);
          }
          return that.data[this.index('query', parameters)];
        };
        this.requery = function(parameters, success, error) {
          that.data[this.index('query', parameters)] = null;
          return that.query(parameters, success, error);
        };
        this.get = function(parameters, success, error) {
          if (that.data[this.index('get', parameters)] == null) {
            that.data[this.index('get', parameters)] = that.resource.get(parameters, success, error);
          }
          return that.data[this.index('get', parameters)];
        };
        this.reget = function(parameters, success, error) {
          that.data[this.index('get', parameters)] = null;
          return that.get(parameters, success, error);
        };
        this.clearCache = function() {
          return that.data = {};
        };
        return this;
      };
    }
  ]);

  resource.factory('GetResource', [
    '$http', function($http) {
      return function(url, isArray, cb) {
        var rsrc, sub_promise;
        if (isArray == null) {
          isArray = false;
        }
        if (isArray) {
          rsrc = [];
        } else {
          rsrc = {};
        }
        rsrc.$resolved = false;
        rsrc.$promise = $http.get(url, {
          cache: true
        });
        sub_promise = rsrc.$promise.then(function(res) {
          var key;
          for (key in res.data) {
            if (res.data.hasOwnProperty(key)) {
              rsrc[key] = res.data[key];
            }
          }
          return rsrc.$resolved = true;
        });
        if (typeof cb === 'function') {
          sub_promise.then(cb);
        }
        return rsrc;
      };
    }
  ]);

}).call(this);
(function() {


}).call(this);
