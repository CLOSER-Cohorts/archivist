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