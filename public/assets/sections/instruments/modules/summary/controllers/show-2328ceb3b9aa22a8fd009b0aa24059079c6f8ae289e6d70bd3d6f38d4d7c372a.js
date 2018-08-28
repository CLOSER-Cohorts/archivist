(function() {
  angular.module('archivist.summary').controller('SummaryShowController', [
    '$scope', '$routeParams', '$filter', 'DataManager', 'Map', 'RealTimeListener', function($scope, $routeParams, $filter, DataManager, Map, RealTimeListener) {
      var k, options, v;
      $scope.object_type = $routeParams.object_type.underscore_to_pascal_case();
      options = Object.lower_everything(Map.map[$scope.object_type]);
      for (k in options) {
        v = options[k];
        options[k] = {};
        options[k][v] = true;
      }
      options['topsequence'] = false;
      return $scope.instrument = DataManager.getInstrument($routeParams.id, options, function() {
        var accepted_columns, data, i, index, j, key, len, obj, row;
        accepted_columns = ['id', 'label', 'literal', 'base_label', 'response_unit_label', 'logic'];
        data = Map.find(DataManager.Data, $scope.object_type);
        $scope.data = [];
        for (index = j = 0, len = data.length; j < len; index = ++j) {
          row = data[index];
          obj = {};
          for (i in row) {
            if (accepted_columns.indexOf(i) !== -1) {
              obj[i] = row[i];
            }
          }
          $scope.data.push(obj);
        }
        $scope.cols = (function() {
          var results;
          results = [];
          for (key in $scope.data[0]) {
            results.push(key);
          }
          return results;
        })();
        $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/instruments',
            active: false
          }, {
            label: $scope.instrument.prefix,
            link: '/instruments/' + $scope.instrument.prefix,
            active: false
          }, {
            label: 'Summary',
            link: false,
            active: false
          }, {
            label: $scope.object_type,
            link: false,
            active: true
          }
        ];
        return console.log($scope);
      });
    }
  ]);

}).call(this);
