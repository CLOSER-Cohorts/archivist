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
