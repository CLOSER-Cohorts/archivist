(function() {
  angular.module('archivist.build').directive('strip', [
    function() {
      return {
        scope: {
          key: '@'
        },
        link: {
          postLink: function(scope, iElement, iAttrs) {
            return iElement.text = iElement.text.replaceAll('ResponseDomain', '');
          }
        }
      };
    }
  ]);

}).call(this);
