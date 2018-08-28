(function() {
  var auth;

  auth = angular.module('archivist.data_manager.auth', ['archivist.data_manager.auth.groups', 'archivist.data_manager.auth.users']);

  auth.factory('Auth', [
    'Groups', 'Users', function(Groups, Users) {
      var Auth;
      Auth = {};
      Auth.Groups = Groups;
      Auth.Users = Users;
      Auth.clearCache = function() {
        Auth.Groups.clearCache();
        return Auth.Users.clearCache();
      };
      return Auth;
    }
  ]);

}).call(this);
