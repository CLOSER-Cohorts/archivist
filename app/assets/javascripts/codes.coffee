codes = angular.module('archivist.codes', [
  'archivist.resource'
])

codes.factory('CodeResolver', [
  ->{
    code_list:(scope, code)->
      scope.code_lists.select_resource_by_id(code.code_list_id)

    category:(scope, code)->
      scope.categories.select_resource_by_id(code.category_id)

    code_lists:(scope, category)->
      (@code_list(scope, code) for code in scope.codes when code.category_id == category.id)

    categories:(scope, code_list)->
      for code in code_list.codes
        code.label = @category(scope, code)['label']
  }
])