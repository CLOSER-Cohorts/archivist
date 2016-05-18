resolution = angular.module(
  'archivist.data_manager.resolution',
  [

  ]
)

resolution.factory(
  'ResolutionService'
  [
    ()->
      service = {}

      service.ConstructResolver = class
        constructor: (constructs)->
          @constructs = constructs

        map:
          CcCondition:  'Conditions'
          CcLoop:       'Loops'
          CcQuestion:   'Questions'
          CcSequence:   'Sequences'
          CcStatement:  'Statements'

        resolve: (to_check, check_against)->
          to_check ?= ['Conditions','Loops','Sequences']

          check_against ?= ['Conditions','Loops','Questions','Sequences','Statements']

          for key, collection of @constructs
            if key in to_check
              for construct in collection
                for child, index in construct.children
                  if child.type?
                    if child.type of @map
                      construct.children[index] = @constructs[@map[child.type]].select_resource_by_id child.id

                if construct.fchildren?
                  for child, index in construct.fchildren
                    if child.type?
                      if child.type of @map
                        construct.fchildren[index] = @constructs[@map[child.type]].select_resource_by_id child.id
                construct.resolved = true

      service.QuestionResolver = class
        constructor: (questions)->
          @questions = questions

        map:
          QuestionItem: 'Items'
          QuestionGrid: 'Grids'

        resolve: (constructs)->
          for construct, index in constructs
            constructs[index].base ?= @questions[@map[construct.question_type]].select_resource_by_id construct.question_id

      service.CodeResolver = class
        constructor: (codes_lists, categories)->
          @code_lists = codes_lists
          @categories = categories

        category: (code)->
          @categories.select_resource_by_id code.category_id

        resolve: ->
          for code_list in @code_lists
            for code, index in code_list.codes
              code_list.codes[index].label = @category(code)['label']

      service
  ]
)