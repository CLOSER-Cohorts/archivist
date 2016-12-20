var testApp = angular.module('testApp', []);

testApp.directive('ngFileModel', [
  '$parse', function($parse) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        var isMultiple, model, modelSetter;
        model = $parse(attrs.ngFileModel);
        isMultiple = attrs.multiple;
        modelSetter = model.assign;
        return element.bind('change', function() {
          var values;
          values = [];
          angular.forEach(element[0].files, function(item) {
            return values.push(item);
          });
          return scope.$apply(function() {
            if (isMultiple) {
              return modelSetter(scope, values);
            } else {
              return modelSetter(scope, values[0]);
            }
          });
        });
      }
    };
  }
]);

testApp.controller('MemberImports', [
'$scope', '$http',
function MemberImports($scope, $http) {
  	console.log('loaded controller');
	$scope.uploadMemberImports = function() {
	  var fd;
	  fd = new FormData();
	  angular.forEach($scope.files, function(item) {
	    var tmp = {type: 'alpha', file: item};
		fd.append('imports[]', tmp);
		console.log(tmp);
	  });
	  $http({
		method: 'POST',
		url: 'localhost:3000/admin/import/instruments',
		data: fd,
		transformRequest: angular.identity,
		headers: {
		  'Content-Type': void 0
		}
	  });
	};
}]);