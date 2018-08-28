(function() {
  var users;

  users = angular.module('archivist.users', ['archivist.flash']);

  users.controller('UserController', [
    '$scope', '$location', '$http', '$route', 'User', 'DataManager', function($scope, $location, $http, $route, User, DataManager) {
      $scope.sign_in = function(cred) {
        $scope.user.set('email', cred.email);
        return $scope.user.sign_in(cred.password).then(function() {
          return $location.path('/instruments');
        }, function() {
          $scope.publish_flash();
          cred.password = "";
          DataManager.clearCache();
          $route.reload();
          return console.log('User logged in.');
        });
      };
      $scope.sign_up = function(details) {
        $scope.user.set('email', details.email);
        $scope.user.set('first_name', details.fname);
        $scope.user.set('last_name', details.lname);
        $scope.user.set('group_id', details.group);
        return $scope.user.sign_up(details.password, details.confirm).then(function() {
          $location.path('/instruments');
          return true;
        }, function() {
          $scope.publish_flash();
          details.password = "";
          details.confirm = "";
          DataManager.clearCache();
          $route.reload();
          return false;
        });
      };
      $http.get('/user_groups/external.json').then(function(res) {
        return $scope.sign_up_groups = res.data;
      });
      return console.log($scope);
    }
  ]);

  users.factory('User', [
    '$http', '$q', '$route', 'Flash', 'DataManager', function($http, $q, $route, Flash, DataManager) {
      return (function() {
        function _Class(email) {
          this.email = email;
          this.logged_in = false;
        }

        _Class.attributes = ['email', 'first_name', 'last_name', 'group', 'group_id', 'role'];

        _Class.prototype.sign_in = function(password) {
          var self;
          self = this;
          return $http.post('/users/sign_in.json', {
            user: {
              email: this.email,
              password: password,
              remember_me: 1
            }
          }).then(function(res) {
            DataManager.clearCache();
            $route.reload();
            self.logged_in = true;
            self.set('first_name', res.data.first_name);
            self.set('last_name', res.data.last_name);
            self.set('group', res.data.group);
            self.set('role', res.data.role);
            return true;
          }, function(res) {
            self.logged_in = false;
            Flash.add('danger', res.data.error);
            return $q.reject(res.data.error);
          });
        };

        _Class.prototype.sign_out = function() {
          var self;
          self = this;
          return $http["delete"]('/users/sign_out.json').then(function() {
            DataManager.clearCache();
            return $route.reload();
          })["finally"](function() {
            return self.logged_in = false;
          });
        };

        _Class.prototype.sign_up = function(password, confirmation) {
          var self;
          self = this;
          return $http.post('/users.json', {
            user: this.get_all_data({
              password: password,
              password_confirmation: confirmation
            })
          }).then(function(res) {
            DataManager.clearCache();
            $route.reload();
            self.logged_in = true;
            return self.set('role', res.data.role);
          }, function(res) {
            self.logged_in = false;
            return Flash.add('danger', res.errors);
          });
        };

        _Class.prototype.is_admin = function() {
          return this.get('role') === 'admin';
        };

        _Class.prototype.is_editor = function() {
          return this.get('role') === 'admin' || this.get('role') === 'editor';
        };

        _Class.prototype.get = function(attribute) {
          return this[attribute];
        };

        _Class.prototype.set = function(attribute, val) {
          return this[attribute] = val;
        };

        _Class.prototype.get_all_data = function(extra) {
          var attribute, i, key, len, output, ref;
          if (extra == null) {
            extra = {};
          }
          output = {};
          ref = this.constructor.attributes;
          for (i = 0, len = ref.length; i < len; i++) {
            attribute = ref[i];
            output[attribute] = this.get(attribute);
          }
          for (key in extra) {
            output[key] = extra[key];
          }
          return output;
        };

        return _Class;

      })();
    }
  ]);

}).call(this);
