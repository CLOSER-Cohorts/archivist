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
