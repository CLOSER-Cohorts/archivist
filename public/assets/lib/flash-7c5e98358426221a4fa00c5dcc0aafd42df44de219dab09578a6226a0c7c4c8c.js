(function() {
  var flash;

  flash = angular.module('archivist.flash', ['ngMessages']);

  flash.factory('Flash', [
    '$interval', function($interval) {
      var LOCAL_STORAGE_KEY, clear, notices, scope, store;
      LOCAL_STORAGE_KEY = 'notices';
      notices = JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY)) || [];
      scope = null;
      store = function() {
        return localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(notices));
      };
      clear = function() {
        notices = [];
        return store();
      };
      return {
        add: function(type, message) {
          notices.push({
            type: type,
            message: message
          });
          store();
          if (document.getElementsByTagName(LOCAL_STORAGE_KEY)) {
            return this.publish(scope);
          }
        },
        publish: function(_scope) {
          _scope.notices = notices;
          return clear();
        },
        set_scope: function(_scope) {
          return scope = _scope;
        },
        listen: function(scope) {},
        clear: this.clear,
        store: this.store
      };
    }
  ]);

}).call(this);
