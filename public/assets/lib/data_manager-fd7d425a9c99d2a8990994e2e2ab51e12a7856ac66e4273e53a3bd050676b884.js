(function() {
  var data_manager;

  data_manager = angular.module('archivist.data_manager', ['archivist.data_manager.map', 'archivist.data_manager.instruments', 'archivist.data_manager.constructs', 'archivist.data_manager.codes', 'archivist.data_manager.response_units', 'archivist.data_manager.response_domains', 'archivist.data_manager.datasets', 'archivist.data_manager.dataset_imports', 'archivist.data_manager.variables', 'archivist.data_manager.variables_instrument', 'archivist.data_manager.resolution', 'archivist.data_manager.stats', 'archivist.data_manager.topics', 'archivist.data_manager.auth', 'archivist.resource']);

  data_manager.factory('DataManager', [
    '$http', '$q', 'Map', 'Instruments', 'Constructs', 'Codes', 'ResponseUnits', 'ResponseDomains', 'ResolutionService', 'GetResource', 'ApplicationStats', 'Topics', 'InstrumentStats', 'Datasets', 'DatasetImports', 'Variables', 'VariablesInstrument', 'Auth', function($http, $q, Map, Instruments, Constructs, Codes, ResponseUnits, ResponseDomains, ResolutionService, GetResource, ApplicationStats, Topics, InstrumentStats, Datasets, DatasetImports, Variables, VariablesInstrument, Auth) {
      var DataManager;
      DataManager = {};
      DataManager.Data = {};
      DataManager.Instruments = Instruments;
      DataManager.Constructs = Constructs;
      DataManager.Codes = Codes;
      DataManager.ResponseUnits = ResponseUnits;
      DataManager.ResponseDomains = ResponseDomains;
      DataManager.Datasets = Datasets;
      DataManager.DatasetImports = DatasetImports;
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
      DataManager.getDatasetImports = function(params, success, error) {
        console.log(DataManager);
        DataManager.Data.DatasetImports = DataManager.DatasetImports.query(params, success, error);
        return DataManager.Data.DatasetImports;
      };
      DataManager.getDatasetImportsx = function(params, success, error) {
        console.log(DataManager);
        DataManager.Data.DatasetImport = DataManager.DatasetImports.get(params);
        return DataManager.Data.DatasetImport;
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
        delete model.suggested_topic;
        return model.$update_topic({
          topic_id: Number.isInteger(topic_id) ? topic_id : null
        });
      };
      DataManager.addSources = function(model, new_sources, x, y) {
        console.log(model);
        return model.$add_mapping({
          sources: {
            id: new_sources,
            x: x,
            y: y
          }
        });
      };
      DataManager.addVariables = function(model, variables) {
        console.log(model);
        return model.$add_mapping({
          variable_names: variables,
          x: null,
          y: null
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
