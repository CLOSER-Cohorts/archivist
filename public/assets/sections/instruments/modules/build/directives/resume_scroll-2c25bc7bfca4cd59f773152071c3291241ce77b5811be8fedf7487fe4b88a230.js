(function() {
  angular.module('archivist.build').directive('resumeScroll', [
    '$timeout', function($timeout) {
      return {
        scope: {
          key: '@'
        },
        link: {
          postLink: function(scope, iElement, iAttrs) {
            $timeout(function() {
              console.log(scope);
              iElement.scrollTop = localStorage.getItem('sidebar-scroll-top');
              return localStorage.removeItem('sidebar-scroll-top');
            });
            return scope.$on('$destroy', function() {
              return localStorage.setItem('sidebar-scroll-top', iElement.scrollTop);
            });
          }
        }
      };
    }
  ]);

}).call(this);
