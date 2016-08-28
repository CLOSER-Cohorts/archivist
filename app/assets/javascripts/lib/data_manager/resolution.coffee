resolution = angular.module(
  'archivist.data_manager.resolution',
  [

  ]
)

construct_resolver_url = URL.createObjectURL(new Blob [
  'var child, collection, construct, i, index, j, k, key, len, len1, len2, ref, ref1, run,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Array.prototype.select_resource_by_id = function(ref_id) {
  var key, output;
  return output = ((function() {
    var i, ref, results;
    results = [];
    for (key = i = 0, ref = this.length; 0 <= ref ? i < ref : i > ref; key = 0 <= ref ? ++i : --i) {
      if (this[key].id === ref_id) {
        results.push(this[key]);
      }
    }
    return results;
  }).call(this))[0];
};

run = function(map, to_check, constructs) {
for (key in constructs) {
  collection = constructs[key];
  if (indexOf.call(to_check, key) >= 0) {
    for (i = 0, len = collection.length; i < len; i++) {
      construct = collection[i];
      ref = construct.children;
      for (index = j = 0, len1 = ref.length; j < len1; index = ++j) {
        child = ref[index];
        if (child.type != null) {
          if (child.type in map) {
            construct.children[index] = constructs[map[child.type]].select_resource_by_id(child.id);
          }
        }
      }
      if (construct.fchildren != null) {
        ref1 = construct.fchildren;
        for (index = k = 0, len2 = ref1.length; k < len2; index = ++k) {
          child = ref1[index];
          if (child.type != null) {
            if (child.type in map) {
              construct.fchildren[index] = constructs[map[child.type]].select_resource_by_id(child.id);
            }
          }
        }
      }
      construct.resolved = true;
    }
  }
}
return constructs;
};
self.addEventListener("message", function(e) { self.postMessage(run(e.data["map"],e.data["to_check"],e.data["constructs"]));}, false);'], type: {'application/javascript'}
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

        worker: new Worker construct_resolver_url

        resolve: (to_check, check_against)->
          to_check ?= ['Conditions','Loops','Sequences']

          check_against ?= ['Conditions','Loops','Questions','Sequences','Statements']

          @worker.addEventListener 'message', (e)->
            @constructs = e.data
          , false

          @worker.postMessage({map: @map, 'to_check': to_check, constructs: @constructs})

          #for key, collection of @constructs
          #  if key in to_check
          #    for construct in collection
          #      for child, index in construct.children
          #        if child.type?
          #          if child.type of @map
          #            construct.children[index] = @constructs[@map[child.type]].select_resource_by_id child.id

          #      if construct.fchildren?
          #        for child, index in construct.fchildren
          #          if child.type?
          #            if child.type of @map
          #              construct.fchildren[index] = @constructs[@map[child.type]].select_resource_by_id child.id
          #      construct.resolved = true

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