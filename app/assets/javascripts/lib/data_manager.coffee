data_manager = angular.module(
  'archivist.data_manager',
  [
    'archivist.data_manager.map',
    'archivist.data_manager.instruments',
    'archivist.data_manager.constructs',
    'archivist.data_manager.codes',
    'archivist.data_manager.resolution',
    'archivist.data_manager.stats',
    'archivist.realtime',
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
    'Constructs',
    'Codes',
    'ResolutionService',
    'RealTimeListener',
    'GetResource',
    'ApplicationStats',
    'InstrumentStats'
    (
      $http,
      $q,
      Map,
      Instruments,
      Constructs,
      Codes,
      ResolutionService,
      RealTimeListener,
      GetResource,
      ApplicationStats,
      InstrumentStats
    )->
      DataManager = {}

      DataManager.Data = {}

      DataManager.Data.ResponseDomains = {}
      DataManager.Data.ResponseUnits = {}

      DataManager.Data.InstrumentStats = {}

      DataManager.Instruments = Instruments
      DataManager.Constructs = Constructs
      DataManager.Codes = Codes

      DataManager.getInstrument = (instrument_id, options = {}, success, error)->

        console.log 'getInstrument'

        DataManager.progress = 0

        options.codes ?= false
        options.constructs ?= false
        options.questions ?= false
        options.rds ?= false
        options.instrument ?= true
        options.topsequence ?= true

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
          DataManager.Data.Constructs.Conditions  =
            DataManager.Constructs.Conditions.query instrument_id: instrument_id
          promises.push DataManager.Data.Constructs.Conditions.$promise.then (collection)->
            for obj, index in collection
              collection[index].type = 'condition'

          DataManager.Data.Constructs.Loops  =
            DataManager.Constructs.Loops.query instrument_id: instrument_id
          promises.push DataManager.Data.Constructs.Loops.$promise.then (collection)->
            for obj, index in collection
              collection[index].type = 'loop'


          # Load Questions
          DataManager.Data.Constructs.Questions   =
            DataManager.Constructs.Questions.cc.query instrument_id: instrument_id
          promises.push DataManager.Data.Constructs.Questions.$promise.then (collection)->
            for obj, index in collection
              collection[index].type = 'question'


          # Load Statements
          DataManager.Data.Constructs.Statements  =
            DataManager.Constructs.Statements.query instrument_id: instrument_id
          promises.push DataManager.Data.Constructs.Statements.$promise.then (collection)->
            for obj, index in collection
              collection[index].type = 'statement'


          # Load Sequences
          DataManager.Data.Constructs.Sequences   =
            DataManager.Constructs.Sequences.query instrument_id: instrument_id
          promises.push DataManager.Data.Constructs.Sequences.$promise.then (collection)->
            console.log 'seqeunce altering'
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


        chunk_size = 100 / promises.length
        for promise in promises
          promise.finally ()->
            DataManager.progress += chunk_size
            if options.progress?
              options.progress(DataManager.progress)

        console.log promises
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

            console.log DataManager.Data.Questions
            console.log DataManager.Data.Instrument.Questions
            console.log 'callbacks called'
            if options.constructs and options.instrument and options.topsequence
              console.log DataManager.Data
              DataManager.Data.Instrument.topsequence = (s for s in DataManager.Data.Instrument.Constructs.Sequences when s.top)[0]


            console.log success
            defer = $.Deferred()
            if options.rds
              rds = DataManager.getResponseDomains instrument_id, false, defer.resolve
              if options.instrument
                DataManager.Data.Instrument.ResponseDomains = rds

            else
              defer.resolve()

            defer.then(
              ->
                console.log DataManager.Data.Instrument.Questions
                success?()
            )


            #if error?
            #  error()
        )

        return DataManager.Data.Instrument

      DataManager.getResponseDomains = (instrument_id, force = false, cb)->
        if (not DataManager.Data.ResponseDomains[instrument_id]?) or force
          DataManager.Data.ResponseDomains[instrument_id] =
            GetResource(
              '/instruments/' + instrument_id + '/response_domains.json',
              true,
              cb
            )
        else
          cb?()

        DataManager.Data.ResponseDomains[instrument_id]

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
        DataManager.ConstructResolver.resolve options

      DataManager.resolveQuestions = ()->
        DataManager.QuestionResolver ?= new ResolutionService.QuestionResolver DataManager.Data.Questions
        DataManager.QuestionResolver.resolve DataManager.Data.Constructs.Questions

      DataManager.resolveCodes = ->
        DataManager.CodeResolver ?= new ResolutionService.CodeResolver(
          DataManager.Data.Codes.CodeLists,
          DataManager.Data.Codes.Categories
        )
        DataManager.CodeResolver.resolve()

      DataManager.getApplicationStats = ()->
        DataManager.Data.AppStats = {$resolved: false}
        DataManager.Data.AppStats.$promise = ApplicationStats
        DataManager.Data.AppStats.$promise.then (res)->
          for key of res.data
            if res.data.hasOwnProperty key
              DataManager.Data.AppStats[key] = res.data[key]
          DataManager.Data.AppStats.$resolved = true
        DataManager.Data.AppStats

      DataManager.getInstrumentStats = (id)->
        DataManager.Data.InstrumentStats[id] = {$resolved: false}
        DataManager.Data.InstrumentStats[id].$promise = InstrumentStats(id)
        DataManager.Data.InstrumentStats[id].$promise.then (res)->
          for key of res.data
            if res.data.hasOwnProperty key
              DataManager.Data.InstrumentStats[id][key] = res.data[key]
          DataManager.Data.InstrumentStats[id].$resolved = true
        DataManager.Data.InstrumentStats[id]

      DataManager.getQuestionItemIDs = ()->
        output = []
        for qi in DataManager.Data.Questions.Items
          output.push {value: qi.id, label: qi.label}
        output

      DataManager.getQuestionGridIDs = ()->
        output = []
        for qg in DataManager.Data.Questions.Grids
          output.push {value: qg.id, label: qg.label}
        output

      DataManager.listener = RealTimeListener (event, message)->
        if message.data?
          for row in message.data
            obj = Map.find(DataManager.Data, row.type).select_resource_by_id row.id
            if obj?
              for key, value of row
                if ['id','type'].indexOf(key) == -1
                  obj[key] = row[key]
            if row.type == 'Instrument' and row.id DataManager.Data.Instrument.id
              for key, value of row
                if ['id','type'].indexOf(key) == -1
                  DataManager.Data.Instrument[key] = row[key]

      DataManager
  ]
)