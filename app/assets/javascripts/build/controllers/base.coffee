angular.module('archivist.build').controller(
  'BaseBuildController',
  [
    '$scope',
    '$routeParams',
    '$location',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    ($scope, $routeParams, $location, Flash, DataManager, RealTimeListener, RealTimeLocking)->

      $scope.page['title'] = $scope.title
      $scope.underscored = $scope.title.toLowerCase().replaceAll(' ','_')
      $scope.main_panel = "partials/build/" + $scope.underscored + ".html"

      $scope.before_instrument_loaded?()

      $scope.instrument = DataManager.getInstrument(
        $routeParams.id,
        $scope.instrument_options,
        ()->
          $scope.page['title'] = $scope.instrument.prefix + ' | ' + $scope.title

          $scope.reset()

          $scope.breadcrumbs = [
            {label: 'Instruments', link: '/instruments', active: false},
            {label: $scope.instrument.prefix, link: '/instruments/' + $scope.instrument.id.toString(), active: false},
            {label: 'Build', link: '/instruments/' + $scope.instrument.id.toString() + '/build', active: false}
            {label: $scope.title, link: false, active: true}
          ]
          $scope.after_instrument_loaded?()
          console.log $scope
      )

      if !$scope.cancel?
        $scope.cancel = () ->
          console.log "cancel called"
          $scope.reset()
          null

      if !$scope.edit_path?
        $scope.edit_path = (obj)->
          if obj?
            terms = [
              'instruments',
              $scope.instrument.id,
              'build'
            ]
            if $scope.extra_url_parameters
              terms = terms.concat $scope.extra_url_parameters

            terms.push (obj.type.replace(/([A-Z])/g, (x,y) -> "_"+y.toLowerCase()).replace /^_/, '') + 's'
            terms.push obj.id
            terms.join('/')

      if !$scope.startEditMode?
        $scope.startEditMode = () ->
          $scope.editMode = true
          console.log $scope.current
          RealTimeLocking.lock({type: $scope.current.type, id: $scope.current.id})
          null

      if !$scope.change_panel?
        $scope.change_panel = (obj) ->
          $location.url $scope.edit_path obj

      $scope.listener = RealTimeListener (event, message)->
        if !$scope.editMode
          $scope.reset()
  ]
)