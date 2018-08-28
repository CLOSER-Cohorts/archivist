(function() {
  angular.module('archivist.build').filter('stripRD', function() {
    return function(item) {
      return item.replace('ResponseDomain', '');
    };
  });

}).call(this);
