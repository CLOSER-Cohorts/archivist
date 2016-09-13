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
        CcCondition:
          Constructs: 'Conditions'
        CcLoop:
          Constructs: 'Loops'
        CcQuestion:
          Constructs: 'Questions'
        CcSequence:
          Constructs: 'Sequences'
        CcStatement:
          Constructs: 'Statements'
        QuestionItem:
          Questions:  'Items'
        QuestionGrid:
          Questions:  'Grids'
        ResponseDomainText:
          ResponseDomains: 'Texts'
        ResponseDomainNumeric:
          ResponseDomains: 'Numerics'
        ResponseDomainDatetime:
          ResponseDomains: 'Datetimes'

      service.find = (obj, ident)->

        dig = (obj, lookup) ->
          output = obj

          if typeof lookup == "object"
            for k,v of lookup
              if lookup.hasOwnProperty k
                output = dig(output[k], v)
          else
            output = output[lookup]

          output

        dig(obj, service.map[ident])

      service.translate = (ident)->

        dig = (lookup)->
          if typeof lookup == "object"
            return dig(lookup[Object.keys(lookup)[0]])
          else
            return lookup

        dig service.map[ident]

      service
  ]
)