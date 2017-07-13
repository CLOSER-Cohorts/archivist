resolution = angular.module(
  'archivist.data_manager.resolution',
  [

  ]
)

resolution.factory(
  'ResolutionService'
  [
    '$timeout',
    '$rootScope',
    ($timeout, $rootScope)->
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

        queue: []

        added_to_queue: 0
        currently_scheduled: 0

        resolve_children: (item)->
          console.log item.children
          for child, index in item.children.slice().reverse()
            if child.type?
              if child.type of @map
                item.children[item.children.length - 1 - index] = @constructs[@map[child.type]].select_resource_by_id child.id

            if item.children[item.children.length - 1 - index].children?
              @queue.unshift item.children[item.children.length - 1 - index]
              @added_to_queue = @added_to_queue + 1

          if item.fchildren?
            for child, index in item.fchildren.slice().reverse()
              if child.type?
                if child.type of @map
                  item.fchildren[item.fchildren.length - 1 - index] = @constructs[@map[child.type]].select_resource_by_id child.id

              if item.fchildren[item.fchildren.length - 1 - index].children?
                @queue.unshift item.fchildren[item.fchildren.length - 1 - index]
                @added_to_queue = @added_to_queue + 1

          item.resolved = true

          self = @
          if @queue.length > @currently_scheduled
            @currently_scheduled += 1
            console.log 'Scheduled resolution'
            $timeout ->
              index = 'resolving:' + self.queue[0].label
              console.time index
              self.resolve_children self.queue.shift()
              console.timeEnd index
              @currently_scheduled -= 1
            , 0, false
          else
            console.log 'call digest'
            $rootScope.$digest()

        broken_resolve: ->
          self = @
          @queue.unshift (seq for seq in @constructs.Sequences when seq.top)[0]
          @added_to_queue = @added_to_queue + 1

          $timeout ->
            self.resolve_children self.queue.shift()
          , 0

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

      service.GroupResolver = class
        constructor: (groups, users)->
          @groups = groups
          @users = users

        resolve: ->
          for group, group_index in @groups
            @groups[group_index].users = []
            for user, user_index in @users
              if group.id == user.group_id
                @users[user_index].group = group.label
                @groups[group_index].users.push user

      service
  ]
)