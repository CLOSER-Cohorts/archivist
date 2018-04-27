Array::select_resource_by_id = (ref_id)->
  output = (@[key] for key in [0...@length] when @[key].id == ref_id)[0]

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


onmessage = (e)->
  data    = e.data['data']
  options = e.data['options']
  types    = if Array.isArray e.data['type'] then e.data['type'] else [e.data['type']]
  for type in types
    console.time 'resolving'
    if type == 'constructs'
      ConstructResolver = new service.ConstructResolver data.Constructs
      ConstructResolver.resolve options
    else if type == 'questions'
      QuestionResolver = new service.QuestionResolver data.Questions
      QuestionResolver.resolve data.Constructs.Questions

    console.timeEnd 'resolving'

  @postMessage data


self.addEventListener "message", onmessage