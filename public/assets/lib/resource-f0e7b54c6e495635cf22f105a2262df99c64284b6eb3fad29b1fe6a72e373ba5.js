(function() {
  var resource;

  resource = angular.module('archivist.resource', ['ngResource']);

  resource.factory('WrappedResource', [
    '$resource', function($resource) {
      return function(path, paramDefaults, actions, options) {
        var that;
        that = this;
        this.data = {};
        if (actions != null) {
          this.actions = actions;
        } else {
          this.actions = {
            save: {
              method: 'PUT'
            },
            create: {
              method: 'POST'
            }
          };
        }
        this.index = function(method, parameters) {
          return path + method + JSON.stringify(parameters);
        };
        this.resource = $resource(path, paramDefaults, this.actions, options);
        this.resource.prototype.save = function(params, success, error) {
          console.trace();
          if (this.id != null) {
            return this.$save(params, success, error);
          } else {
            return this.$create(params, success, error);
          }
        };
        this.query = function(parameters, success, error) {
          if (that.data[this.index('query', parameters)] == null) {
            that.data[this.index('query', parameters)] = that.resource.query(parameters, function(value, responseHeaders) {
              var i, k, len, obj, v;
              for (i = 0, len = value.length; i < len; i++) {
                obj = value[i];
                for (k in parameters) {
                  v = parameters[k];
                  obj[k] = v;
                }
              }
              if (success != null) {
                return success(value, responseHeaders);
              }
            }, error);
          }
          return that.data[this.index('query', parameters)];
        };
        this.requery = function(parameters, success, error) {
          that.data[this.index('query', parameters)] = null;
          return that.query(parameters, success, error);
        };
        this.get = function(parameters, success, error) {
          if (that.data[this.index('get', parameters)] == null) {
            that.data[this.index('get', parameters)] = that.resource.get(parameters, success, error);
          }
          return that.data[this.index('get', parameters)];
        };
        this.reget = function(parameters, success, error) {
          that.data[this.index('get', parameters)] = null;
          return that.get(parameters, success, error);
        };
        this.clearCache = function() {
          return that.data = {};
        };
        return this;
      };
    }
  ]);

  resource.factory('GetResource', [
    '$http', function($http) {
      return function(url, isArray, cb) {
        var rsrc, sub_promise;
        if (isArray == null) {
          isArray = false;
        }
        if (isArray) {
          rsrc = [];
        } else {
          rsrc = {};
        }
        rsrc.$resolved = false;
        rsrc.$promise = $http.get(url, {
          cache: true
        });
        sub_promise = rsrc.$promise.then(function(res) {
          var key;
          for (key in res.data) {
            if (res.data.hasOwnProperty(key)) {
              rsrc[key] = res.data[key];
            }
          }
          return rsrc.$resolved = true;
        });
        if (typeof cb === 'function') {
          sub_promise.then(cb);
        }
        return rsrc;
      };
    }
  ]);

}).call(this);
