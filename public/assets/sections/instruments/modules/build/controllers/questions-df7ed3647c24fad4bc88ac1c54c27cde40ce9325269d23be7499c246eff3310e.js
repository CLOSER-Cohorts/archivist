(function() {
  angular.module('archivist.build').controller('BuildQuestionsController', [
    '$controller', '$scope', '$routeParams', '$location', '$timeout', 'Flash', 'DataManager', 'RealTimeListener', 'RealTimeLocking', function($controller, $scope, $routeParams, $location, $timeout, Flash, DataManager, RealTimeListener, RealTimeLocking) {
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
            $scope.reset();
            return $scope.load_sidebar();
          }, function() {
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
          if ($scope.current != null) {
            RealTimeLocking.unlock({
              type: $scope.current.type,
              id: $scope.current.id
            });
          }
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
        DataManager: DataManager,
        RealTimeListener: RealTimeListener,
        RealTimeLocking: RealTimeLocking
      });
    }
  ]);

}).call(this);
