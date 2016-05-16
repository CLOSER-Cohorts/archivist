codes = angular.module('archivist.data_manager.codes', [
  'archivist.data_manager.codes.code_lists',
  'archivist.data_manager.codes.categories'
])

codes.factory(
  'Codes',
  [
    'CodeLists',
    'Categories',
    'CodeResolver',
    (
      CodeLists,
      Categories,
      CodeResolver,
    )->
      Codes = {}

      Codes.CodeLists       = CodeLists
      Codes.Categories      = Categories
      Codes.CodeResolver    = CodeResolver

      Codes.clearCache = ->
        Codes.CodeLists.clearCache()
        Codes.Categories.clearCache()

      Codes
  ]
)

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