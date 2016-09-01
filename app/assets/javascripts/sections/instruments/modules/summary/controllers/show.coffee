angular.module('archivist.summary').controller(
  'SummaryShowController',
  [
    '$scope',
    '$routeParams',
    '$filter',
    'DataManager',
    'Map',
    'RealTimeListener',
    ($scope, $routeParams, $filter, DataManager, Map, RealTimeListener)->

      $scope.object_type = $routeParams.object_type.underscore_to_pascal_case()

      options = Object.lower_everything Map.map[$scope.object_type]

      for k, v of options
        options[k] = {}
        options[k][v] = true

      options['topsequence'] = false

      $scope.instrument = DataManager.getInstrument $routeParams.id, options, ->
        accepted_columns = ['id', 'label', 'literal', 'base_label', 'response_unit_label', 'logic']
        data = Map.find DataManager.Data, $scope.object_type
        $scope.data = []
        for row, index in data
          obj = {}

          for i of row
            if accepted_columns.indexOf(i) isnt -1
              obj[i] = row[i]

          $scope.data.push obj

        $scope.cols = (key for key of $scope.data[0])

        $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/instruments',
            active: false
          },
          {
            label: $scope.instrument.prefix,
            link: '/instruments/' + $scope.instrument.id.toString(),
            active: false
          },
          {
            label: 'Summary',
            link: false,
            active: false
          },
          {
            label: $scope.object_type,
            link: false,
            active: true
          },
        ]

        console.log $scope
   ]
)