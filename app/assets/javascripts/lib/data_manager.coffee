data_manager = angular.module(
  'archivist.data_manager',
  [
    'archivist.data_manager.instruments',
    'archivist.data_manager.constructs',
    'archivist.data_manager.resolution'
  ]
)

data_manager.factory(
  'DataManager',
  [
    '$http',
    '$q',
    'Instruments',
    'Constructs',
    'ResolutionService'
    (
      $http,
      $q,
      Instruments,
      Constructs,
      ResolutionService
    )->
      DataManager = {}

      DataManager.Data = {}

      DataManager.Instruments = Instruments
      DataManager.Constructs = Constructs

      DataManager.getInstrument = (instrument_id, options = {}, success, error)->

        DataManager.progress = 0

        options.constructs ?= false
        options.questions ?= false
        options.rds ?= false
        options.instrument ?= true
        options.topsequence ?= true

        promises = []

        DataManager.Data.Instrument  = DataManager.Instruments.get({id: instrument_id})
        promises.push DataManager.Data.Instrument .$promise

        if options.constructs

          DataManager.Data.Constructs ?= {}
          DataManager.Data.Constructs.Conditions  =
            DataManager.Constructs.Conditions.query({instrument_id: instrument_id}, (collection)->
              for obj, index in collection
                collection[index].type = 'condition'

              if options.instrument
                DataManager.Data.Instrument.Conditions = DataManager.Data.Constructs.Conditions
            )
          promises.push DataManager.Data.Constructs.Conditions.$promise

          DataManager.Data.Constructs.Loops       =
            DataManager.Constructs.Loops.query({instrument_id: instrument_id}, (collection)->
              for obj, index in collection
                collection[index].type = 'loop'

              if options.instrument
                DataManager.Data.Instrument.Loops = DataManager.Data.Constructs.Loops
            )
          promises.push DataManager.Data.Constructs.Loops.$promise

          DataManager.Data.Constructs.Questions   =
            DataManager.Constructs.Questions.cc.query({instrument_id: instrument_id}, (collection)->
              for obj, index in collection
                collection[index].type = 'question'

              if options.instrument
                DataManager.Data.Instrument.Questions = DataManager.Data.Constructs.Questions
            )
          promises.push DataManager.Data.Constructs.Questions.$promise

          DataManager.Data.Constructs.Statements  =
            DataManager.Constructs.Statements.query({instrument_id: instrument_id}, (collection)->
              for obj, index in collection
                collection[index].type = 'statement'

              if options.instrument
                DataManager.Data.Instrument.Statements = DataManager.Data.Constructs.Statements
            )
          promises.push DataManager.Data.Constructs.Statements.$promise

          DataManager.Data.Constructs.Sequences   =
            DataManager.Constructs.Sequences.query({instrument_id: instrument_id}, (collection)->
              for obj, index in collection
                collection[index].type = 'sequence'

              if options.instrument
                DataManager.Data.Instrument.Sequences = DataManager.Data.Constructs.Sequences
            )
          promises.push DataManager.Data.Constructs.Sequences.$promise

        if options.questions

          DataManager.Data.Questions ?= {}
          DataManager.Data.Questions.Items  =
            DataManager.Constructs.Questions.item.query({instrument_id: instrument_id}, (collection)->
              for obj, index in collection
                collection[index].type = 'question-item'

              if options.instrument
                DataManager.Data.Instrument.Questions ?= {}
                DataManager.Data.Instrument.Questions.Items = DataManager.Data.Questions.Items
            )
          promises.push DataManager.Data.Questions.Items.$promise

          DataManager.Data.Questions ?= {}
          DataManager.Data.Questions.Grids  =
            DataManager.Constructs.Questions.grid.query({instrument_id: instrument_id}, (collection)->
              for obj, index in collection
                collection[index].type = 'question-grid'

                if options.instrument
                  DataManager.Data.Instrument.Questions ?= {}
                  DataManager.Data.Instrument.Questions.Grids = DataManager.Data.Questions.Grids
            )
          promises.push DataManager.Data.Questions.Grids.$promise

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
            if options.constructs and options.instrument and options.topsequence
              DataManager.Data.Instrument.topsequence = (s for s in DataManager.Data.Instrument.Sequences when s.top)[0]

            if options.rds and options.instrument
              $http.get('/instruments/' + instrument_id + '/response_domains.json').success((data)->
                DataManager.Data.Instrument.rds = data
              )

            if success?
              success()

            if error?
              error()
        )

        return DataManager.Data.Instrument

      DataManager.resolveConstructs = (options)->
        DataManager.ConstructResolver ?= new ResolutionService.ConstructResolver DataManager.Data.Constructs
        DataManager.ConstructResolver.resolve options

      DataManager.resolveQuestions = ()->
        DataManager.QuestionResolver ?= new ResolutionService.QuestionResolver DataManager.Data.Questions
        DataManager.QuestionResolver.resolve DataManager.Data.Constructs.Questions

      DataManager
  ]
)