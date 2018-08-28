(function() {
  var codes;

  codes = angular.module('archivist.data_manager.codes', ['archivist.data_manager.codes.code_lists', 'archivist.data_manager.codes.categories']);

  codes.factory('Codes', [
    'CodeLists', 'Categories', 'CodeResolver', function(CodeLists, Categories, CodeResolver) {
      var Codes;
      Codes = {};
      Codes.CodeLists = CodeLists;
      Codes.Categories = Categories;
      Codes.CodeResolver = CodeResolver;
      Codes.clearCache = function() {
        Codes.CodeLists.clearCache();
        return Codes.Categories.clearCache();
      };
      return Codes;
    }
  ]);

  codes.factory('CodeResolver', [
    function() {
      return {
        code_list: function(scope, code) {
          return scope.code_lists.select_resource_by_id(code.code_list_id);
        },
        category: function(scope, code) {
          return scope.categories.select_resource_by_id(code.category_id);
        },
        code_lists: function(scope, category) {
          var code, i, len, ref, results;
          ref = scope.codes;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            code = ref[i];
            if (code.category_id === category.id) {
              results.push(this.code_list(scope, code));
            }
          }
          return results;
        },
        categories: function(scope, code_list) {
          var code, i, len, ref, results;
          ref = code_list.codes;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            code = ref[i];
            results.push(code.label = this.category(scope, code)['label']);
          }
          return results;
        }
      };
    }
  ]);

}).call(this);
