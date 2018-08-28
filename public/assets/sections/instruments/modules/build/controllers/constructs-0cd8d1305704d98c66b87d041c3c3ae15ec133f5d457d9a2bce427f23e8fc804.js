(function() {
  angular.module('archivist.build').controller('BuildConstructsController', [
    '$controller', '$scope', '$routeParams', '$location', '$filter', '$http', '$timeout', 'bsLoadingOverlayService', 'Flash', 'DataManager', 'RealTimeListener', 'RealTimeLocking', function($controller, $scope, $routeParams, $location, $filter, $http, $timeout, bsLoadingOverlayService, Flash, DataManager, RealTimeListener, RealTimeLocking) {
      console.time('end to end');
      $scope.title = 'Constructs';
      $scope.details_bar = true;
      $scope.hide_edit_buttons = true;
      $scope.extra_url_parameters = ['constructs'];
      $scope.instrument_options = {
        constructs: true,
        questions: true,
        rus: true
      };
      $scope.index = {};
      $scope.details_path = function() {
        return 'partials/build/details/' + $routeParams.construct_type + '.html';
      };
      $scope.setIndex = function(parent_id, parent_type, branch) {
        if (branch == null) {
          branch = null;
        }
        if (parent_id != null) {
          $scope.index.parent_id = parent_id;
          $scope.index.parent_type = parent_type;
        } else {
          $scope.index.parent_id = $scope.instrument.topsequence.id;
          $scope.index.parent_type = 'sequence';
        }
        return $scope.index.branch = branch;
      };
      $scope.$on('$routeUpdate', function(scope, next, current) {
        return $scope.reset();
      });
      $scope.change_panel = function(obj) {
        $location.search({
          construct_type: obj.type,
          construct_id: obj.id
        });
        return $scope.editMode = (obj.type != null) && (obj.id != null);
      };
      $scope.treeOptions = {
        dropped: function() {
          var positionUpdater;
          bsLoadingOverlayService.start();
          $scope.updates = [];
          positionUpdater = function(parent) {
            var child_dimensions, child_key, dimension, i, index, len, results;
            child_dimensions = ['children', 'fchildren'];
            results = [];
            for (index = i = 0, len = child_dimensions.length; i < len; index = ++i) {
              dimension = child_dimensions[index];
              if (parent[dimension] != null) {
                results.push((function() {
                  var results1;
                  results1 = [];
                  for (child_key in parent[dimension]) {
                    if (parent[dimension].hasOwnProperty(child_key)) {
                      if (parent[dimension][child_key].position !== (parseInt(child_key)) + 1 || parent[dimension][child_key].parent !== parent.id || (parent[dimension][child_key].branch !== index && Number.isInteger(parent[dimension][child_key].branch))) {
                        $scope.updates.push({
                          id: parent[dimension][child_key].id,
                          type: parent[dimension][child_key].type,
                          position: (parseInt(child_key)) + 1,
                          parent: {
                            id: parent.id,
                            type: parent.type
                          },
                          branch: index
                        });
                        parent[dimension][child_key].position = $scope.updates[$scope.updates.length - 1]['position'];
                        parent[dimension][child_key].parent = $scope.updates[$scope.updates.length - 1]['parent'];
                      }
                      results1.push(positionUpdater(parent[dimension][child_key]));
                    } else {
                      results1.push(void 0);
                    }
                  }
                  return results1;
                })());
              } else {
                results.push(void 0);
              }
            }
            return results;
          };
          positionUpdater($scope.instrument.topsequence);
          return $http.post('/instruments/' + $scope.instrument.id.toString() + '/reorder_ccs.json', {
            updates: $scope.updates
          })["finally"](function() {
            return bsLoadingOverlayService.stop();
          });
        }
      };
      $scope.toggle = function(scope) {
        return scope.toggle();
      };
      $scope["delete"] = function() {
        var arr, index;
        arr = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's'];
        index = arr.get_index_by_id(parseInt($routeParams.construct_id));
        if (index != null) {
          return arr[index].$delete({}, function() {
            var obj_to_remove, scan;
            obj_to_remove = arr[index].$$hashKey;
            arr.splice(index, 1);
            scan = function(obj, key) {
              var child, i, j, len, len1, ref, ref1;
              if (obj.children !== void 0) {
                ref = obj.children;
                for (index = i = 0, len = ref.length; i < len; index = ++i) {
                  child = ref[index];
                  if (child.$$hashKey === key) {
                    obj.children.splice(index, 1);
                    return true;
                  } else {
                    if (scan(child, key)) {
                      return true;
                    }
                  }
                }
                if (obj.fchildren !== void 0) {
                  ref1 = obj.fchildren;
                  for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
                    child = ref1[index];
                    if (child.$$hashKey === key) {
                      obj.fchildren.splice(index, 1);
                      return true;
                    } else {
                      if (scan(child, key)) {
                        return true;
                      }
                    }
                  }
                }
              }
              return false;
            };
            scan($scope.instrument.topsequence, obj_to_remove);
            return $timeout(function() {
              return $scope.change_panel({
                type: null,
                id: null
              });
            }, 0);
          });
        }
      };
      $scope.save = function() {
        var arr, index;
        arr = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's'];
        if ($routeParams.construct_id === 'new') {
          arr.push($scope.current);
          index = arr.length - 1;
          arr[index].instrument_id = $routeParams.id;
        } else {
          angular.copy($scope.current, arr.select_resource_by_id(parseInt($routeParams.construct_id)));
          index = arr.get_index_by_id(parseInt($routeParams.construct_id));
        }
        return arr[index].save({}, function(value, rh) {
          var parent;
          value['instrument_id'] = $scope.instrument.id;
          value['type'] = $routeParams.construct_type;
          Flash.add('success', 'Construct updated successfully!');
          if ($routeParams.construct_id === 'new') {
            parent = DataManager.Data.Instrument.Constructs[$scope.index.parent_type.capitalizeFirstLetter() + 's'].select_resource_by_id($scope.index.parent_id);
            if ($scope.index.branch === 0 || $scope.index.branch === null) {
              parent.children.push(arr[index]);
            } else {
              parent.fchildren.push(arr[index]);
            }
            $scope.change_panel(arr[index]);
          }
          $scope.change_panel({
            type: null,
            id: null
          });
          return $scope.reset();
        }, function() {
          Flash.add('danger', 'Construct failed to update');
          return console.error("Construct failed to update");
        });
      };
      $scope.reset = function() {
        var cc, i, len, ref;
        if (($routeParams.construct_type != null) && !isNaN(parseInt($routeParams.construct_id))) {
          ref = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's'];
          for (i = 0, len = ref.length; i < len; i++) {
            cc = ref[i];
            if (cc.type.pascal_case_to_underscore() === $routeParams.construct_type && cc.id.toString() === $routeParams.construct_id.toString()) {
              $scope.current = angular.copy(cc);
              break;
            }
          }
        }
        return null;
      };
      $scope.build_ru_options = function() {
        var i, len, ref, results, ru;
        $scope.details.ru_options = [];
        ref = $scope.instrument.ResponseUnits;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          ru = ref[i];
          results.push($scope.details.ru_options.push({
            value: ru.id,
            label: ru.label
          }));
        }
        return results;
      };
      $scope.after_instrument_loaded = function() {
        var constructSorter, sortChildren;
        console.time('after instrument');
        constructSorter = function(a, b) {
          return a.position > b.position;
        };
        if (!$scope.instrument.topsequence.resolved) {
          DataManager.resolveConstructs();
          DataManager.resolveQuestions();
          sortChildren = function(parent) {
            var child, i, j, len, len1, ref, ref1, results;
            if (parent.children != null) {
              parent.children.sort(constructSorter);
              ref = parent.children;
              for (i = 0, len = ref.length; i < len; i++) {
                child = ref[i];
                sortChildren(child);
              }
              if (parent.fchildren != null) {
                parent.fchildren.sort(constructSorter);
                ref1 = parent.fchildren;
                results = [];
                for (j = 0, len1 = ref1.length; j < len1; j++) {
                  child = ref1[j];
                  results.push(sortChildren(child));
                }
                return results;
              }
            }
          };
          sortChildren($scope.instrument.topsequence);
        }
        $scope.details = {};
        $scope.details.options = DataManager.getQuestionIDs();
        $scope.build_ru_options();
        console.timeEnd('after instrument');
        return console.timeEnd('end to end');
      };
      $scope.save_ru = function(new_interviewee) {
        DataManager.Data.ResponseUnits.push(new DataManager.ResponseUnits.resource({
          label: new_interviewee.label,
          instrument_id: $routeParams.id
        }));
        return DataManager.Data.ResponseUnits[DataManager.Data.ResponseUnits.length - 1].save({}, function(value, rh) {
          value['instrument_id'] = $scope.instrument.id;
          return $scope.build_ru_options();
        });
      };
      $scope["new"] = function(cc_type) {
        var resource;
        if (cc_type === 'question') {
          resource = DataManager.Constructs.Questions.cc.resource;
        } else {
          resource = DataManager.Constructs[cc_type.capitalizeFirstLetter() + 's'].resource;
        }
        $scope.current = new resource({
          type: cc_type,
          parent: {
            id: $scope.index.parent_id,
            type: $scope.index.parent_type
          },
          branch: $scope.index.branch
        });
        $location.search({
          construct_type: cc_type,
          construct_id: 'new'
        });
        $scope.reset();
        return $scope.editMode = true;
      };
      console.time('load base');
      $controller('BaseBuildController', {
        $scope: $scope,
        $routeParams: $routeParams,
        $location: $location,
        Flash: Flash,
        DataManager: DataManager,
        RealTimeListener: RealTimeListener,
        RealTimeLocking: RealTimeLocking
      });
      return console.timeEnd('load base');
    }
  ]);

  angular.module('archivist.build').controller('BuildConstructsFirstBranchController', [
    '$scope', function($scope) {
      return $scope.branch = $scope.obj.type === 'condition' ? 0 : null;
    }
  ]);

  angular.module('archivist.build').controller('BuildConstructsSecondBranchController', [
    '$scope', function($scope) {
      return $scope.branch = 1;
    }
  ]);

}).call(this);
