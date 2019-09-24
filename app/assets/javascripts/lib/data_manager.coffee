data_manager = angular.module(
  'archivist.data_manager',
  [
    'archivist.data_manager.map',
    'archivist.data_manager.instruments',
    'archivist.data_manager.instrument_imports',
    'archivist.data_manager.constructs',
    'archivist.data_manager.codes',
    'archivist.data_manager.response_units',
    'archivist.data_manager.response_domains',
    'archivist.data_manager.datasets',
    'archivist.data_manager.dataset_imports',
    'archivist.data_manager.variables',
    'archivist.data_manager.variables_instrument',
    'archivist.data_manager.resolution',
    'archivist.data_manager.stats',
    'archivist.data_manager.topics',
    'archivist.data_manager.auth',
    'archivist.resource'
  ]
)

data_manager.factory(
  'DataManager',
  [
    '$http',
    '$q',
    'Map',
    'Instruments',
    'InstrumentImports',
    'Constructs',
    'Codes',
    'ResponseUnits',
    'ResponseDomains',
    'ResolutionService',
    'GetResource',
    'ApplicationStats',
    'Topics',
    'InstrumentStats',
    'Datasets',
    'DatasetImports',
    'Variables',
    'VariablesInstrument',
    'Auth',
    (
      $http,
      $q,
      Map,
      Instruments,
      InstrumentImports,
      Constructs,
      Codes,
      ResponseUnits,
      ResponseDomains,
      ResolutionService,
      GetResource,
      ApplicationStats,
      Topics,
      InstrumentStats,
      Datasets,
      DatasetImports,
      Variables,
      VariablesInstrument,
      Auth
    )->
      DataManager = {}

      DataManager.Data = {}

      DataManager.Instruments       = Instruments
      DataManager.InstrumentImports = InstrumentImports
      DataManager.Constructs        = Constructs
      DataManager.Codes             = Codes
      DataManager.ResponseUnits     = ResponseUnits
      DataManager.ResponseDomains   = ResponseDomains
      DataManager.Datasets          = Datasets
      DataManager.DatasetImports    = DatasetImports
      DataManager.Variables         = Variables
      DataManager.VariablesInstrument = VariablesInstrument
      DataManager.Auth              = Auth

      DataManager.clearCache = ->
        DataManager.Data                    = {}
        DataManager.Data.ResponseDomains    = {}
        DataManager.Data.ResponseUnits      = {}
        DataManager.Data.InstrumentStats    = {}
        DataManager.Data.Users              = {}
        DataManager.Data.Groups             = {}

        DataManager.Instruments.clearCache()
        DataManager.Constructs.clearCache()
        DataManager.Codes.clearCache()
        DataManager.ResponseUnits.clearCache()
        DataManager.Datasets.clearCache()
        DataManager.Variables.clearCache()
        DataManager.VariablesInstrument.clearCache()
        DataManager.Auth.clearCache()

      DataManager.clearCache()

      DataManager.getInstruments = (params, success, error)->
        DataManager.Data.Instruments = DataManager.Instruments.query params, success, error
        DataManager.Data.Instruments

      DataManager.getDatasets = (params, success, error) ->
        DataManager.Data.Datasets = DataManager.Datasets.query params, success, error
        DataManager.Data.Datasets

      DataManager.getDatasetImports = (params, success, error) ->
        console.log(DataManager)
        DataManager.Data.DatasetImports = DataManager.DatasetImports.query params, success, error
        DataManager.Data.DatasetImports

      DataManager.getDatasetImportsx = (params, success, error) ->
        console.log(DataManager)
        DataManager.Data.DatasetImport = DataManager.DatasetImports.get params
        DataManager.Data.DatasetImport

      DataManager.getInstrumentImports = (params, success, error) ->
        console.log(DataManager)
        DataManager.Data.InstrumentImports = DataManager.InstrumentImports.query params, success, error
        DataManager.Data.InstrumentImports

      DataManager.getInstrumentImport = (params, success, error) ->
        console.log(DataManager)
        DataManager.Data.InstrumentImport = DataManager.InstrumentImports.get params
        DataManager.Data.InstrumentImport

      DataManager.getInstrument = (instrument_id, options = {}, success, error)->
        console.log 'getInstrument'

        DataManager.progress = 0

        options.codes ?= false
        options.constructs ?= false
        options.questions ?= false
        options.rds ?= false
        options.rus ?= false
        options.instrument ?= true
        options.topsequence ?= true
        options.variables ?= false

        promises = []

        DataManager.Data.Instrument  = DataManager.Instruments.get({id: instrument_id})
        promises.push DataManager.Data.Instrument.$promise

        if options.codes

          DataManager.Data.Codes ?= {}
          DataManager.Data.Codes.CodeLists =
            DataManager.Codes.CodeLists.query instrument_id: instrument_id
          promises.push DataManager.Data.Codes.CodeLists.$promise

          DataManager.Data.Codes.Categories =
            DataManager.Codes.Categories.query instrument_id: instrument_id
          promises.push DataManager.Data.Codes.Categories.$promise

        if options.constructs

          DataManager.Data.Constructs ?= {}
          if options.constructs == true || options.constructs.conditions

            DataManager.Data.Constructs.Conditions  =
              DataManager.Constructs.Conditions.query instrument_id: instrument_id
            promises.push DataManager.Data.Constructs.Conditions.$promise.then (collection)->
              for obj, index in collection
                collection[index].type = 'condition'

          if options.constructs == true || options.constructs.loops

            DataManager.Data.Constructs.Loops  =
              DataManager.Constructs.Loops.query instrument_id: instrument_id
            promises.push DataManager.Data.Constructs.Loops.$promise.then (collection)->
              for obj, index in collection
                collection[index].type = 'loop'

          if options.constructs == true || options.constructs.questions

            # Load Questions
            DataManager.Data.Constructs.Questions   =
              DataManager.Constructs.Questions.cc.query instrument_id: instrument_id
            promises.push DataManager.Data.Constructs.Questions.$promise.then (collection)->
              for obj, index in collection
                collection[index].type = 'question'

          if options.constructs == true || options.constructs.statements

            # Load Statements
            DataManager.Data.Constructs.Statements  =
              DataManager.Constructs.Statements.query instrument_id: instrument_id
            promises.push DataManager.Data.Constructs.Statements.$promise.then (collection)->
              for obj, index in collection
                collection[index].type = 'statement'

          if options.constructs == true || options.constructs.sequences

            # Load Sequences
            DataManager.Data.Constructs.Sequences   =
              DataManager.Constructs.Sequences.query instrument_id: instrument_id
            promises.push DataManager.Data.Constructs.Sequences.$promise.then (collection)->
              console.log 'sequence altering'
              for obj, index in collection
                collection[index].type = 'sequence'

            if options.instrument
              if typeof DataManager.Data.Instrument.Constructs == 'undefined'
                DataManager.Data.Instrument.Constructs = {}
              DataManager.Data.Instrument.Constructs.Sequences = DataManager.Data.Constructs.Sequences
              true

        if options.questions

          DataManager.Data.Questions ?= {}
          DataManager.Data.Questions.Items  =
            DataManager.Constructs.Questions.item.query instrument_id: instrument_id
          promises.push DataManager.Data.Questions.Items.$promise


          DataManager.Data.Questions.Grids  =
            DataManager.Constructs.Questions.grid.query instrument_id: instrument_id
          promises.push DataManager.Data.Questions.Grids.$promise

        if options.rds
          DataManager.Data.ResponseDomains = {}

          DataManager.Data.ResponseDomains.Codes =
            DataManager.ResponseDomains.Codes.query instrument_id: instrument_id
          promises.push DataManager.Data.ResponseDomains.Codes.$promise

          DataManager.Data.ResponseDomains.Datetimes =
            DataManager.ResponseDomains.Datetimes.query instrument_id: instrument_id
          promises.push DataManager.Data.ResponseDomains.Datetimes.$promise

          DataManager.Data.ResponseDomains.Numerics =
            DataManager.ResponseDomains.Numerics.query instrument_id: instrument_id
          promises.push DataManager.Data.ResponseDomains.Numerics.$promise

          DataManager.Data.ResponseDomains.Texts =
            DataManager.ResponseDomains.Texts.query instrument_id: instrument_id
          promises.push DataManager.Data.ResponseDomains.Texts.$promise

        if options.rus
          DataManager.Data.ResponseUnits =
            DataManager.ResponseUnits.query instrument_id: instrument_id
          promises.push DataManager.Data.ResponseUnits.$promise

        if options.variables
          DataManager.Data.Variables =
            DataManager.VariablesInstrument.query instrument_id: instrument_id
          promises.push DataManager.Data.Variables.$promise

        chunk_size = 100 / promises.length
        for promise in promises
          promise.finally ()->
            DataManager.progress += chunk_size
            if options.progress?
              options.progress(DataManager.progress)

        $q.all(
          promises
        )
        .then(
          ->
            console.log 'All promises resolved'
            if options.instrument
              if options.constructs
                DataManager.Data.Instrument.Constructs = {}
                DataManager.Data.Instrument.Constructs.Conditions = DataManager.Data.Constructs.Conditions
                DataManager.Data.Instrument.Constructs.Loops = DataManager.Data.Constructs.Loops
                DataManager.Data.Instrument.Constructs.Questions = DataManager.Data.Constructs.Questions
                DataManager.Data.Instrument.Constructs.Sequences = DataManager.Data.Constructs.Sequences
                DataManager.Data.Instrument.Constructs.Statements = DataManager.Data.Constructs.Statements

              if options.questions
                DataManager.Data.Instrument.Questions ?= {}
                DataManager.Data.Instrument.Questions.Items = DataManager.Data.Questions.Items
                DataManager.Data.Instrument.Questions.Grids = DataManager.Data.Questions.Grids

              if options.codes
                DataManager.Data.Instrument.CodeLists = DataManager.Data.Codes.CodeLists

              if options.rds
                DataManager.groupResponseDomains()

              if options.rus
                DataManager.Data.Instrument.ResponseUnits = DataManager.Data.ResponseUnits

              if options.variables
                DataManager.Data.Instrument.Variables = DataManager.Data.Variables

            console.log 'callbacks called'
            if options.constructs and options.instrument and options.topsequence
              DataManager.Data.Instrument.topsequence = (s for s in DataManager.Data.Instrument.Constructs.Sequences when s.top)[0]

            success?()

            #if error?
            #  error()
        )

        return DataManager.Data.Instrument

      DataManager.getDataset = (dataset_id, options = {}, success, error) ->
        options.variables ?= false
        options.questions ?= false

        promises = []

        DataManager.Data.Dataset  = DataManager.Datasets.get {id: dataset_id, questions: options.questions}

        promises.push DataManager.Data.Dataset.$promise

        if options.variables

          DataManager.Data.Variables =
            DataManager.Variables.query dataset_id: dataset_id
          promises.push DataManager.Data.Variables.$promise

        $q.all(
          promises
        )
        .then(
          ->
            if options.variables
              DataManager.Data.Dataset.Variables = DataManager.Data.Variables

            success?()
        )

        return DataManager.Data.Dataset

      DataManager.groupResponseDomains = ->
        DataManager.Data.Instrument.ResponseDomains = DataManager.Data.ResponseDomains.Datetimes.concat(
          DataManager.Data.ResponseDomains.Numerics,
          DataManager.Data.ResponseDomains.Texts,
          DataManager.Data.ResponseDomains.Codes
        )

      DataManager.getResponseUnits = (instrument_id, force = false, cb)->
        if (not DataManager.Data.ResponseUnits[instrument_id]?) or force
          DataManager.Data.ResponseUnits[instrument_id] =
            GetResource(
              '/instruments/' + instrument_id + '/response_units.json',
              true,
              cb
            )
        else
          cb?()

      DataManager.resolveConstructs = (options)->
        DataManager.ConstructResolver ?= new ResolutionService.ConstructResolver DataManager.Data.Constructs
        DataManager.ConstructResolver.broken_resolve()

      DataManager.resolveQuestions = ->
        DataManager.QuestionResolver ?= new ResolutionService.QuestionResolver DataManager.Data.Questions
        DataManager.QuestionResolver.resolve DataManager.Data.Constructs.Questions

      DataManager.resolveCodes = ->
        DataManager.CodeResolver ?= new ResolutionService.CodeResolver(
          DataManager.Data.Codes.CodeLists,
          DataManager.Data.Codes.Categories
        )
        DataManager.CodeResolver.resolve()

      DataManager.getApplicationStats = ->
        DataManager.Data.AppStats = {$resolved: false}
        DataManager.Data.AppStats.$promise = ApplicationStats
        DataManager.Data.AppStats.$promise.then (res)->
          for key of res.data
            if res.data.hasOwnProperty key
              DataManager.Data.AppStats[key] = res.data[key]
          DataManager.Data.AppStats.$resolved = true
        DataManager.Data.AppStats

      DataManager.getTopics = (options = {})->
        options.nested ?= false
        options.flattened ?= false
        if options.nested
          DataManager.Data.Topics = Topics.getNested()
        if options.flattened
          DataManager.Data.Topics = Topics.getFlattenedNest()
        DataManager.Data.Topics

      DataManager.updateTopic = (model, topic_id)->
        console.log(model)
        delete model.topic
        delete model.suggested_topic
        model.$update_topic({topic_id: if Number.isInteger(topic_id) then topic_id else null })

      DataManager.addSources = (model, new_sources, x, y)->
        console.log(model)
        model.$add_mapping {
            sources:
              id: new_sources
              x: x
              y: y
          }

      DataManager.addVariables = (model, variables)->
        console.log(model)
        model.$add_mapping {
            variable_names: variables
            x: null
            y: null
          }

      DataManager.getInstrumentStats = (id, cb)->
        DataManager.Data.InstrumentStats[id] = {$resolved: false}
        DataManager.Data.InstrumentStats[id].$promise = InstrumentStats(id)
        DataManager.Data.InstrumentStats[id].$promise.then (res)->
          for key of res.data
            if res.data.hasOwnProperty key
              DataManager.Data.InstrumentStats[id][key] = res.data[key]
          DataManager.Data.InstrumentStats[id].$resolved = true
          if cb?
            cb.call()
        DataManager.Data.InstrumentStats[id]

      DataManager.getQuestionItemIDs = ->
        output = []
        for qi in DataManager.Data.Questions.Items
          output.push {value: qi.id, label: qi.label, type: 'QuestionItem'}
        output

      DataManager.getQuestionGridIDs = ->
        output = []
        for qg in DataManager.Data.Questions.Grids
          output.push {value: qg.id, label: qg.label, type: 'QuestionGrid'}
        output

      DataManager.getQuestionIDs = ->
        DataManager.getQuestionItemIDs().concat DataManager.getQuestionGridIDs()

      DataManager.getUsers = ->
        promises = []

        DataManager.Data.Users = DataManager.Auth.Users.query()
        promises.push DataManager.Data.Users.$promise

        DataManager.Data.Groups = DataManager.Auth.Groups.query()
        promises.push DataManager.Data.Groups.$promise

        $q.all(
          promises
        )
        .then ->
          DataManager.GroupResolver ?= new ResolutionService.GroupResolver(
            DataManager.Data.Groups,
            DataManager.Data.Users
          )
          DataManager.GroupResolver.resolve()

      DataManager
  ]
)
