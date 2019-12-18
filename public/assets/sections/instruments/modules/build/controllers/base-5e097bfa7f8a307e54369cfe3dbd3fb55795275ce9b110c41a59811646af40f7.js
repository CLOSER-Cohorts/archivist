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
      if ($scope.openFragmentXML == null) {
        $scope.openFragmentXML = function() {
          console.log($scope.current);
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
