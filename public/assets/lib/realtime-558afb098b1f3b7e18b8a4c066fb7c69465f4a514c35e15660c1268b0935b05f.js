(function() {
  var realtime;

  realtime = angular.module('archivist.realtime', ['ngRoute', 'archivist.flash']);

  realtime.factory('RealTimeConnection', [
    '$rootScope', '$timeout', 'Flash', function($rootScope, $timeout, Flash) {
      var service;
      service = {};
      service.socket = io(window.socket_url);
      service.socket.on('disconnect', function() {
        return $rootScope.$apply(function() {
          return $rootScope.realtimeStatus = false;
        });
      });
      service.socket.on('connect', function() {
        return $timeout(function() {
          return $rootScope.realtimeStatus = true;
        });
      });
      service.socket.on('rt-update', function(message) {
        return $rootScope.$emit('rt-update', message);
      });
      return service;
    }
  ]);

  realtime.factory('RealTimeListener', [
    '$rootScope', '$http', function($rootScope, $http) {
      var listener;
      listener = (function() {
        function _Class($rootScope, callback) {
          this.handler = $rootScope.$on('rt-update', function(event, message) {
            return $rootScope.$apply(function() {
              var no_more_pending_requests;
              return no_more_pending_requests = $rootScope.$watch(function() {
                return $http.pendingRequests.length;
              }, function() {
                if ($http.pendingRequests.length < 1) {
                  callback(event, JSON.parse(message));
                  return no_more_pending_requests();
                }
              });
            });
          });
        }

        return _Class;

      })();
      listener.prototype.stop = function() {
        return this.handler();
      };
      return function(callback) {
        return new listener($rootScope, callback);
      };
    }
  ]);

  realtime.factory('RealTimeLocking', [
    '$rootScope', '$routeParams', 'RealTimeConnection', function($rootScope, $routeParams, RTC) {
      var service;
      service = {};
      service.locks = [];
      service.comparator = {
        CodeList: function(id) {
          return $routeParams['code_list_id'] === id.toString();
        },
        QuestionItem: function(id) {
          return $routeParams['question_type'] === 'question-item' && $routeParams['question_id'] === id.toString();
        },
        QuestionGrid: function(id) {
          return $routeParams['question_type'] === 'question-grid' && $routeParams['question_id'] === id.toString();
        }
      };
      service.lock = function(obj) {
        return RTC.socket.emit('lock', JSON.stringify(obj));
      };
      service.unlock = function(obj) {
        return RTC.socket.emit('unlock', JSON.stringify(obj));
      };
      RTC.socket.on('locks-updated', function(message) {
        var i, len, lock, locks, results;
        locks = JSON.parse(message);
        $('.lockable').prop('disabled', false);
        results = [];
        for (i = 0, len = locks.length; i < len; i++) {
          lock = locks[i];
          console.log(lock);
          if (service.comparator[lock.type](lock.id)) {
            results.push($('.lockable').prop('disabled', true));
          } else {
            results.push(void 0);
          }
        }
        return results;
      });
      return service;
    }
  ]);

}).call(this);
