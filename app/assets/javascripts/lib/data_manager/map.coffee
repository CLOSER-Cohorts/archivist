map = angular.module(
  'archivist.data_manager.map',
  [

  ]
)

map.factory(
  'Map'
  [
    ()->
      service = {}

      service.map =
        Instrument:   'Instruments'
        CcCondition:  'Conditions'
        CcLoop:       'Loops'
        CcQuestion:   'Questions'
        CcSequence:   'Sequences'
        CcStatement:  'Statements'
        QuestionItem:
          Questions:  'Items'
        QuestionGrid:
          Questions:  'Grids'

      service.find = (obj, ident)->

        dig = (obj, lookup) ->
          output = obj

          if typeof lookup == "object"
            for k,v of lookup
              output = dig(output[k], v)
          else
            output = output[lookup]

          output

        dig(obj, service.map[ident])

      service
  ]
)