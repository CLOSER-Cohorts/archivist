(function() {
  var slice = [].slice;

  angular.module('archivist.build').controller('BuildCodeListsController', [
    '$controller', '$scope', '$routeParams', '$location', '$filter', '$timeout', 'Flash', 'DataManager', function($controller, $scope, $routeParams, $location, $filter, $timeout, Flash, DataManager) {
      console.log('called code_list controller');
      $scope.load_sidebar = function() {
        var get_count_from_used_by, obj;
        get_count_from_used_by = function(cl) {
          cl.count = cl.used_by.length;
          return cl;
        };
        $scope.sidebar_objs = ((function() {
          var j, len, ref, results;
          ref = $scope.instrument.CodeLists;
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            obj = ref[j];
            results.push(get_count_from_used_by(obj));
          }
          return results;
        })()).sort_by_property();
        DataManager.Data.Codes.Categories.$promise.then(function() {
          return $scope.categories = DataManager.Data.Codes.Categories;
        });
        return $timeout(function() {
          var offset;
          offset = localStorage.getItem('sidebar_scroll');
          if (offset !== null) {
            console.log(offset);
            jQuery('.sidebar').scrollTop(offset);
            return localStorage.removeItem('sidebar_scroll');
          }
        }, 0);
      };
      $scope["delete"] = function() {
        var index;
        index = $scope.instrument.CodeLists.get_index_by_id(parseInt($routeParams.code_list_id));
        if (index != null) {
          return $scope.instrument.CodeLists[index].$delete({}, function() {
            $scope.instrument.CodeLists.splice(index, 1);
            $scope.load_sidebar();
            return $timeout(function() {
              if ($scope.instrument.CodeLists.length > 0) {
                return $scope.change_panel($scope.instrument.CodeLists[0]);
              } else {
                return $scope.change_panel({
                  type: 'CodeList',
                  id: 'new'
                });
              }
            }, 0);
          });
        }
      };
      $scope.save = function() {
        var index;
        console.log($scope.current);
        if ($routeParams.code_list_id === 'new') {
          $scope.instrument.CodeLists.push($scope.current);
          index = $scope.instrument.CodeLists.length - 1;
          $scope.instrument.CodeLists[index].instrument_id = $routeParams.id;
        } else {
          angular.copy($scope.current, $scope.instrument.CodeLists.select_resource_by_id(parseInt($routeParams.code_list_id)));
          index = $scope.instrument.CodeLists.get_index_by_id(parseInt($routeParams.code_list_id));
        }
        $scope.instrument.CodeLists[index].save({}, function(value, rh) {
          value['instrument_id'] = $scope.instrument.id;
          Flash.add('success', 'Code list updated successfully!');
          $scope.reset();
          $scope.load_sidebar();
          DataManager.Data.Codes.Categories = DataManager.Codes.Categories.requery({
            instrument_id: $scope.instrument.id
          });
          DataManager.Data.ResponseDomains.Codes = DataManager.ResponseDomains.Codes.requery({
            instrument_id: $scope.instrument.id
          });
          DataManager.Data.Codes.Categories.$promise.then(function() {
            return $scope.categories = DataManager.Data.Codes.Categories;
          });
          return DataManager.Data.ResponseDomains.Codes.$promise.then(function() {
            return DataManager.groupResponseDomains();
          });
        }, function(value, rh) {
          return Flash.add('danger', 'Code list failed to update! ' + value.data.error_sentence);
        });
        return DataManager.Data.ResponseDomains[$routeParams.id] = null;
      };
      $scope.title = 'Code Lists';
      $scope.instrument_options = {
        codes: true
      };
      $scope.reset = function() {
        console.log("reset called");
        if (DataManager.CodeResolver == null) {
          DataManager.resolveCodes();
        }
        if (!isNaN($routeParams.code_list_id)) {
          $scope.current = angular.copy($scope.instrument.CodeLists.select_resource_by_id(parseInt($routeParams.code_list_id)));
          $scope.editMode = false;
        }
        if ($routeParams.code_list_id === 'new') {
          $scope.editMode = true;
          return $scope.current = new DataManager.Codes.CodeLists.resource({
            codes: []
          });
        }
      };
      $scope["new"] = function() {
        return $scope.change_panel({
          type: 'CodeList',
          id: 'new'
        });
      };
      $scope.removeCode = function(code) {
        var c, i, results;
        $scope.current.codes = (function() {
          var j, len, ref, results;
          ref = $scope.current.codes;
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            c = ref[j];
            if (c.$$hashKey !== code.$$hashKey) {
              results.push(c);
            }
          }
          return results;
        })();
        $scope.current.codes.sort(function(a, b) {
          return a.order - b.order;
        });
        results = [];
        for (i in $scope.current.codes) {
          results.push($scope.current.codes[i].order = i);
        }
        return results;
      };
      $scope.moveUp = function(code) {
        return $scope.moveCode(code, -1);
      };
      $scope.moveDown = function(code) {
        return $scope.moveCode(code, 1);
      };
      $scope.moveCode = function(code, shift) {
        var being_moved, i, original_index, ref, results;
        original_index = $scope.current.codes.findIndex(function(c) {
          return c.$$hashKey === code.$$hashKey;
        });
        if (original_index + shift < 0 || original_index + shift >= $scope.current.codes.length) {
          return false;
        }
        being_moved = $scope.current.codes.splice(original_index, 1);
        (ref = $scope.current.codes).splice.apply(ref, [original_index + shift, 0].concat(slice.call(being_moved)));
        results = [];
        for (i in $scope.current.codes) {
          results.push($scope.current.codes[i].order = parseInt(i));
        }
        return results;
      };
      $scope.after_instrument_loaded = function() {
        $scope.categories = DataManager.Data.Codes.Categories;
        console.log($scope.sidebar_objs);
        $scope.load_sidebar();
        return $scope.$watch('current.newValue', function(newVal, oldVal, scope) {
          var i;
          console.log(newVal, oldVal, scope);
          if (newVal !== oldVal) {
            if (newVal != null) {
              scope.current.codes.push({
                id: null,
                value: newVal,
                category: null
              });
              for (i in $scope.current.codes) {
                $scope.current.codes[i].order = parseInt(i);
              }
              $scope.current.newValue = null;
              return $timeout(function() {
                var strLength;
                jQuery('.code-value').last().focus();
                strLength = jQuery('.code-value').last().val().length * 2;
                return jQuery('.code-value').last()[0].setSelectionRange(strLength, strLength);
              }, 0);
            }
          }
        });
      };
      return $controller('BaseBuildController', {
        $scope: $scope,
        $routeParams: $routeParams,
        $location: $location,
        Flash: Flash,
        DataManager: DataManager
      });
    }
  ]);

}).call(this);
