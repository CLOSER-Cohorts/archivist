(function() {
  var build;

  build = angular.module('archivist.build', ['templates', 'ngRoute', 'archivist.flash', 'archivist.data_manager']);

  build.config([
    '$routeProvider', 'treeConfig', function($routeProvider, treeConfig) {
      $routeProvider.when('/instruments/:id/build', {
        templateUrl: 'partials/build/index.html',
        controller: 'BuildMenuController'
      }).when('/instruments/:id/build/code_lists/:code_list_id?', {
        templateUrl: 'partials/build/editor.html',
        controller: 'BuildCodeListsController'
      }).when('/instruments/:id/build/response_domains/:response_domain_type?/:response_domain_id?', {
        templateUrl: 'partials/build/editor.html',
        controller: 'BuildResponseDomainsController'
      }).when('/instruments/:id/build/questions/:question_type?/:question_id?', {
        templateUrl: 'partials/build/editor.html',
        controller: 'BuildQuestionsController'
      }).when('/instruments/:id/build/constructs', {
        templateUrl: 'partials/build/editor.html',
        controller: 'BuildConstructsController',
        reloadOnSearch: false
      });
      treeConfig.placeholderClass = 'a-tree-placeholder a-construct list-group-item';
      treeConfig.hiddenClass = 'a-tree-hidden';
      return treeConfig.dragClass = 'a-tree-drag';
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').controller('BaseBuildController', [
    '$scope', '$routeParams', '$location', '$timeout', 'Flash', 'DataManager', function($scope, $routeParams, $location, $timeout, Flash, DataManager) {
      $scope.page['title'] = $scope.title;
      $scope.underscored = $scope.title.toLowerCase().replaceAll(' ', '_');
      $scope.main_panel = "partials/build/" + $scope.underscored + ".html";
      $scope.url_path_args = $location.path().split('/');
      $scope.newMode = $scope.url_path_args.slice(0).pop() === 'new';
      if (typeof $scope.before_instrument_loaded === "function") {
        $scope.before_instrument_loaded();
      }
      $scope.instrument = DataManager.getInstrument($routeParams.id, $scope.instrument_options, function() {
        $scope.page['title'] = $scope.instrument.prefix + ' | ' + $scope.title;
        $scope.reset();
        $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/instruments',
            active: false
          }, {
            label: $scope.instrument.prefix,
            link: '/instruments/' + $scope.instrument.id.toString(),
            active: false
          }, {
            label: 'Build',
            link: '/instruments/' + $scope.instrument.id.toString() + '/build',
            active: false
          }, {
            label: $scope.title,
            link: false,
            active: true
          }
        ];
        $timeout(function() {
          return jQuery('.first-field').first().focus();
        }, 0);
        if (typeof $scope.after_instrument_loaded === "function") {
          $scope.after_instrument_loaded();
        }
        return console.log($scope);
      });
      if ($scope.cancel == null) {
        $scope.cancel = function() {
          console.log("cancel called");
          if ($scope.newMode) {
            $scope.editMode = $scope.newMode = false;
          } else {
            $scope.reset();
          }
          return null;
        };
      }
      if ($scope.edit_path == null) {
        $scope.edit_path = function(obj) {
          var terms;
          terms = ['instruments', $scope.instrument.id, 'build'];
          if ($scope.extra_url_parameters) {
            terms = terms.concat($scope.extra_url_parameters);
          }
          if (obj != null) {
            if (obj.type != null) {
              terms.push((obj.type.replace(/([A-Z])/g, function(x, y) {
                return "_" + y.toLowerCase();
              }).replace(/^_/, '')) + 's');
            }
            terms.push(obj.id);
          }
          return terms.join('/');
        };
      }
      if ($scope.startEditMode == null) {
        $scope.startEditMode = function() {
          $scope.editMode = true;
          console.log($scope.current);
          return null;
        };
      }
      if ($scope.startFragmentFormMode == null) {
        $scope.startFragmentFormMode = function() {
          $scope.fragmentFormMode = true;
          console.log($scope.current);
          return null;
        };
      }
      if ($scope.endFragmentFormMode == null) {
        $scope.endFragmentFormMode = function() {
          $scope.fragmentFormMode = false;
          $scope.current.fragment_xml = '';
          return null;
        };
      }
      if ($scope.openFragmentXML == null) {
        $scope.openFragmentXML = function() {
          window.open("/instruments/" + $scope.current.instrument_id + "/question_items/" + $scope.current.id + ".xml");
          return null;
        };
      }
      if ($scope.change_panel == null) {
        return $scope.change_panel = function(obj) {
          localStorage.setItem('sidebar_scroll', jQuery('.sidebar').scrollTop());
          return $location.url($scope.edit_path(obj));
        };
      }
    }
  ]);

}).call(this);
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
          results.push($scope.current.codes[i].order = parseInt(i));
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
(function() {
  angular.module('archivist.build').controller('BuildConstructsController', [
    '$controller', '$scope', '$routeParams', '$location', '$filter', '$http', '$timeout', 'bsLoadingOverlayService', 'Flash', 'DataManager', function($controller, $scope, $routeParams, $location, $filter, $http, $timeout, bsLoadingOverlayService, Flash, DataManager) {
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
        var arr, index, obj;
        arr = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's'];
        index = arr.get_index_by_id(parseInt($routeParams.construct_id));
        if (index != null) {
          obj = arr[index];
          if (obj.children === void 0 || confirm("Deleting this construct will also delete all of it's children. Are you sure you want to delete this construct?")) {
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
        }
      };
      $scope.save_construct = function() {
        var arr, index;
        arr = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's'];
        console.log('<<<<<<<<');
        console.log('Arr variable: ');
        console.log(arr);
        console.log('<<<<<<<<');
        if ($routeParams.construct_id === 'new') {
          console.info('Adding a new construct');
          arr.push($scope.current);
          index = arr.length - 1;
          arr[index].instrument_id = $routeParams.id;
        } else {
          console.info('Construct id: ' + $routeParams.construct_id);
          console.info('Saving an existing construct');
          console.log('-------------------------------------------------------');
          console.log('Current scope: ');
          console.log($scope.current);
          console.log('-------------------------------------------------------');
          angular.copy($scope.current, arr.select_resource_by_id(parseInt($routeParams.construct_id)));
          index = arr.get_index_by_id(parseInt($routeParams.construct_id));
          console.log('-------------------------------------------------------');
          console.log('Array index: ' + index);
          console.log('Parent id: ' + $scope.current.parent_id + ' | ' + 'Parent type: ' + $scope.current.parent_type);
          console.log('-------------------------------------------------------');
        }
        return arr[index].save({}, function(value, rh) {
          var child, child_obj, i, j, len, len1, parent, ref, ref1, type;
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
          } else {
            if (value.children !== void 0) {
              ref = value.children;
              for (index = i = 0, len = ref.length; i < len; index = ++i) {
                child = ref[index];
                type = child.type.replace('Cc', '');
                child_obj = DataManager.Data.Instrument.Constructs[type.capitalizeFirstLetter() + 's'].select_resource_by_id(child.id);
                value.children[index] = child_obj;
              }
            }
            if (value.fchildren !== void 0) {
              ref1 = value.fchildren;
              for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
                child = ref1[index];
                type = child.type.replace('Cc', '');
                child_obj = DataManager.Data.Instrument.Constructs[type.capitalizeFirstLetter() + 's'].select_resource_by_id(child.id);
                value.fchildren[index] = child_obj;
              }
            }
          }
          $scope.change_panel({
            type: null,
            id: null
          });
          return $scope.reset();
        }, function() {
          Flash.add('danger', 'Construct failed to update');
          return console.error("Construct failed to update - save_construct (Cannot connect to Redis)");
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
        return $scope.editMode = true;
      };
      console.time('load base');
      $controller('BaseBuildController', {
        $scope: $scope,
        $routeParams: $routeParams,
        $location: $location,
        Flash: Flash,
        DataManager: DataManager
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
(function() {
  angular.module('archivist.build').controller('BuildMenuController', [
    '$scope', '$routeParams', 'DataManager', function($scope, $routeParams, DataManager) {
      $scope.code_lists_url = '/instruments/' + $routeParams.id + '/build/code_lists';
      $scope.response_domains_url = '/instruments/' + $routeParams.id + '/build/response_domains';
      $scope.questions_url = '/instruments/' + $routeParams.id + '/build/questions';
      $scope.constructs_url = '/instruments/' + $routeParams.id + '/build/constructs';
      $scope.summary_url = function(arg) {
        return '/instruments/' + $routeParams.id + '/summary/' + arg;
      };
      return $scope.instrument = DataManager.getInstrumentStats($routeParams.id, function() {
        $scope.stats = $scope.instrument.stats;
        return $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/instruments',
            active: false
          }, {
            label: $scope.instrument.prefix,
            link: '/instruments/' + $routeParams.id,
            active: false
          }, {
            label: 'Build',
            link: false,
            active: true
          }
        ];
      });
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').controller('BuildQuestionsController', [
    '$controller', '$scope', '$routeParams', '$location', '$timeout', 'Flash', 'DataManager', function($controller, $scope, $routeParams, $location, $timeout, Flash, DataManager) {
      $scope.load_sidebar = function() {
        return $scope.sidebar_objs = $scope.instrument.Questions.Items.concat($scope.instrument.Questions.Grids).sort_by_property();
      };
      $scope.add_rd = function(rd) {
        if ($routeParams.question_type === 'question_items') {
          if ($scope.current.rds == null) {
            $scope.current.rds = [];
          }
          return $scope.current.rds.push(rd);
        } else {
          $scope.current_grid_column.rd = rd;
          jQuery('#add-rd').modal('hide');
          return true;
        }
      };
      $scope.remove_rd = function(rd_or_col) {
        var index;
        if ($routeParams.question_type === 'question_items') {
          index = $scope.current.rds.indexOf(rd_or_col);
          return $scope.current.rds.splice(index, 1);
        } else {
          return rd_or_col.rd = null;
        }
      };
      $scope["delete"] = function() {
        var index, qtype;
        if ($routeParams.question_type === 'question_items') {
          qtype = 'Items';
        } else {
          qtype = 'Grids';
        }
        if (qtype != null) {
          index = $scope.instrument.Questions[qtype].get_index_by_id(parseInt($routeParams.question_id));
          if (index != null) {
            return $scope.instrument.Questions[qtype][index].$delete({}, function() {
              $scope.instrument.Questions[qtype].splice(index, 1);
              $scope.load_sidebar();
              return $timeout(function() {
                if ($scope.instrument.Questions[qtype].length > 0) {
                  return $scope.change_panel($scope.instrument.Questions[qtype][0]);
                } else {
                  return $scope.change_panel({
                    type: $routeParams.question_type,
                    id: 'new'
                  });
                }
              }, 0);
            });
          }
        }
      };
      $scope.select_x_axis = function() {
        return $scope.current.cols = angular.copy($scope.instrument.CodeLists.select_resource_by_id($scope.current.horizontal_code_list_id).codes);
      };
      $scope.set_grid_column = function(col) {
        return $scope.current_grid_column = col;
      };
      $scope.save = function() {
        var index, qtype;
        if ($routeParams.question_type === 'question_items') {
          qtype = 'Items';
        } else {
          qtype = 'Grids';
        }
        if (qtype != null) {
          if ($routeParams.question_id === 'new') {
            $scope.instrument.Questions[qtype].push($scope.current);
            index = $scope.instrument.Questions[qtype].length - 1;
            $scope.instrument.Questions[qtype][index].instrument_id = $routeParams.id;
          } else {
            angular.copy($scope.current, $scope.instrument.Questions[qtype].select_resource_by_id(parseInt($routeParams.question_id)));
            index = $scope.instrument.Questions[qtype].get_index_by_id(parseInt($routeParams.question_id));
          }
          return $scope.instrument.Questions[qtype][index].save({}, function(value, rh) {
            value['instrument_id'] = $scope.instrument.id;
            Flash.add('success', 'Question updated successfully!');
            window.location.href = "/instruments/" + $scope.current.instrument_id + "/build/questions/" + $routeParams.question_type + "/" + value['id'];
            $scope.reset();
            return $scope.load_sidebar();
          }, function(value, rh) {
            $scope.errors = value.data;
            return console.log("error");
          });
        }
      };
      $scope.title = 'Questions';
      $scope.extra_url_parameters = ['questions'];
      $scope.instrument_options = {
        questions: true,
        rds: true,
        codes: true
      };
      $scope.reset = function() {
        console.log("reset called");
        if ($routeParams.question_type != null) {
          if ($routeParams.question_type === 'question_items') {
            $scope.current = angular.copy($scope.instrument.Questions.Items.select_resource_by_id(parseInt($routeParams.question_id)));
            $scope.title = 'Question Item';
          } else {
            $scope.current = angular.copy($scope.instrument.Questions.Grids.select_resource_by_id(parseInt($routeParams.question_id)));
            $scope.title = 'Question Grid';
          }
          $scope.editMode = false;
          $scope.fragmentFormMode = false;
          $scope.errors = void 0;
          if ($routeParams.question_id === 'new') {
            $scope.editMode = true;
            if ($routeParams.question_type === 'question_items') {
              $scope.current = new DataManager.Constructs.Questions.item.resource({});
              $scope.current.type = 'QuestionItem';
            } else if ($routeParams.question_type === 'question_grids') {
              $scope.current = new DataManager.Constructs.Questions.grid.resource({});
              $scope.current.type = 'QuestionGrid';
            }
          }
        }
        return null;
      };
      $scope["new"] = function(type) {
        if (type == null) {
          type = false;
        }
        if (type === false) {
          jQuery('#new-question').modal('show');
        } else {
          $timeout(function() {
            return $scope.change_panel({
              type: type,
              id: 'new'
            });
          }, 0);
        }
        return null;
      };
      $scope.after_instrument_loaded = function() {
        $scope.load_sidebar();
        DataManager.resolveCodes();
        return console.log($scope.sidebar_objs);
      };
      return $controller('BaseBuildController', {
        $scope: $scope,
        $routeParams: $routeParams,
        $location: $location,
        $timeout: $timeout,
        Flash: Flash,
        DataManager: DataManager
      });
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').controller('BuildResponseDomainsController', [
    '$controller', '$scope', '$routeParams', '$location', '$filter', '$timeout', 'Flash', 'DataManager', 'Map', function($controller, $scope, $routeParams, $location, $filter, $timeout, Flash, DataManager, Map) {
      $scope.load_sidebar = function() {
        return $scope.sidebar_objs = $filter('excludeRDC')($scope.instrument.ResponseDomains).sort_by_property();
      };
      $scope.title = 'Response Domains';
      $scope.extra_url_parameters = ['response_domains'];
      $scope.instrument_options = {
        rds: true
      };
      $scope["delete"] = function() {
        var index, rd_type;
        switch ($routeParams.response_domain_type) {
          case 'response_domain_texts':
            rd_type = 'ResponseDomainText';
            break;
          case 'response_domain_datetimes':
            rd_type = 'ResponseDomainDatetime';
            break;
          case 'response_domain_numerics':
            rd_type = 'ResponseDomainNumeric';
            break;
          default:
            rd_type = false;
        }
        if (rd_type != null) {
          index = $scope.instrument.ResponseDomains.get_index_by_id_and_type(parseInt($routeParams.response_domain_id), rd_type);
          if (index != null) {
            return $scope.instrument.ResponseDomains[index].$delete({}, function() {
              $scope.instrument.ResponseDomains.splice(index, 1);
              $scope.load_sidebar();
              return $timeout(function() {
                if ($scope.instrument.ResponseDomains.length > 0) {
                  return $scope.change_panel($scope.instrument.ResponseDomains[0]);
                } else {
                  return $scope.change_panel({
                    type: rd_type,
                    id: 'new'
                  });
                }
              }, 0);
            });
          }
        }
      };
      $scope.save = function() {
        var arr, index, key, rd_type, res;
        switch ($routeParams.response_domain_type) {
          case 'response_domain_texts':
            rd_type = 'ResponseDomainText';
            break;
          case 'response_domain_datetimes':
            rd_type = 'ResponseDomainDatetime';
            break;
          case 'response_domain_numerics':
            rd_type = 'ResponseDomainNumeric';
            break;
          case 'new':
            rd_type = 'new';
            break;
          default:
            rd_type = false;
        }
        if (rd_type) {
          if (rd_type === 'new') {
            res = Map.find(DataManager, $scope.current.type);
            arr = Map.find(DataManager.Data, $scope.current.type);
            console.log(arr);
            arr.push(new res.resource());
            index = arr.length - 1;
            for (key in $scope.current) {
              arr[index][key] = $scope.current[key];
            }
            arr[index]['instrument_id'] = $routeParams.id;
          } else {
            arr = $scope.instrument.ResponseDomains;
            index = arr.get_index_by_id_and_type(parseInt($routeParams.response_domain_id), rd_type);
            angular.copy($scope.current, arr[index]);
          }
          return arr[index].save({}, function(value, rh) {
            value['instrument_id'] = $scope.instrument.id;
            Flash.add('success', 'Response Domain updated successfully!');
            DataManager.groupResponseDomains();
            $scope.reset();
            return $scope.load_sidebar();
          }, function() {
            return console.log("error");
          });
        }
      };
      $scope.reset = function() {
        var i, len, rd, ref;
        if (($routeParams.response_domain_type != null) && ($routeParams.response_domain_id != null)) {
          ref = $scope.instrument.ResponseDomains;
          for (i = 0, len = ref.length; i < len; i++) {
            rd = ref[i];
            if (rd.type.pascal_case_to_underscore() + 's' === $routeParams.response_domain_type && rd.id.toString() === $routeParams.response_domain_id) {
              $scope.current = angular.copy(rd);
              $scope.editMode = false;
              break;
            }
          }
        }
        if ($routeParams.response_domain_type === 'new') {
          $scope.editMode = true;
          $scope.current = {};
        }
        return null;
      };
      $scope["new"] = function() {
        $timeout(function() {
          return $scope.change_panel({
            type: null,
            id: 'new'
          });
        }, 0);
        return null;
      };
      $scope.after_instrument_loaded = function() {
        return $scope.load_sidebar();
      };
      return $controller('BaseBuildController', {
        $scope: $scope,
        $routeParams: $routeParams,
        $location: $location,
        $timeout: $timeout,
        Flash: Flash,
        DataManager: DataManager
      });
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').directive('resumeScroll', [
    '$timeout', function($timeout) {
      return {
        scope: {
          key: '@'
        },
        link: {
          postLink: function(scope, iElement, iAttrs) {
            $timeout(function() {
              console.log(scope);
              iElement.scrollTop = localStorage.getItem('sidebar-scroll-top');
              return localStorage.removeItem('sidebar-scroll-top');
            });
            return scope.$on('$destroy', function() {
              return localStorage.setItem('sidebar-scroll-top', iElement.scrollTop);
            });
          }
        }
      };
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').directive('strip', [
    function() {
      return {
        scope: {
          key: '@'
        },
        link: {
          postLink: function(scope, iElement, iAttrs) {
            return iElement.text = iElement.text.replaceAll('ResponseDomain', '');
          }
        }
      };
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').filter('excludeRDC', function() {
    return function(items) {
      var output;
      output = [];
      angular.forEach(items, function(item) {
        if (item.type !== 'ResponseDomainCode') {
          return output.push(item);
        }
      });
      return output;
    };
  });

}).call(this);
(function() {
  angular.module('archivist.build').filter('stripRD', function() {
    return function(item) {
      return item.replace('ResponseDomain', '');
    };
  });

}).call(this);
