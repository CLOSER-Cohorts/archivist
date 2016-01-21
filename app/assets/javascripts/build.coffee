build = angular.module('archivist.build', [
  'templates',
  'ngRoute',
  'archivist.flash',
  'archivist.instruments',
  'archivist.code_lists',
  'archivist.categories',
  'archivist.codes'
])

build.factory('builder', ['',

  ()->

    instrument: null

    {
      initalise: (id)->
        #grab instrument
    }
])

build.config(['$routeProvider',
  ($routeProvider)->
    $routeProvider
    .when('/instruments/:id/build',
      templateUrl: 'partials/build/index.html'
      controller: 'BuildMenuController'
    )
    .when('/instruments/:id/build/code_lists/:code_list_id?',
      templateUrl: 'partials/build/code_lists.html'
      controller: 'BuildCodeListsController'
    )
    .when('/instruments/:id/build/response_domains',
      templateUrl: 'partials/build/response_domains.html'
      controller: 'BuildResponseDomainsController'
    )
    .when('/instruments/:id/build/questions',
      templateUrl: 'partials/build/questions.html'
      controller: 'BuildQuestionsController'
    )
    .when('/instruments/:id/build/constructs',
      templateUrl: 'partials/build/constructs.html'
      controller: 'BuildConstructsController'
    )
])

build.controller('BuildMenuController',
  [
    '$scope'
    '$routeParams',
    ($scope, $routeParams)->
      $scope.code_lists_url = '/instruments/' + $routeParams.id + '/build/code_lists'
  ])

build.controller('BuildCodeListsController',
  [
    '$scope'
    '$routeParams',
    '$q',
    '$location',
    'flash',
    'InstrumentsArchive',
    'CodeListsArchive',
    'CategoriesArchive',
    'CodesArchive',
    'CodeResolver',
    ($scope, $routeParams, $q, $location, Flash, Instruments, CodeLists, Categories, Codes, CodeResolver)->
      $scope.instrument = Instruments.get {id: $routeParams.id}
      $scope.code_lists = CodeLists.query {instrument_id: $routeParams.id}
      $scope.categories = Categories.query {instrument_id: $routeParams.id}
      $scope.codes = Codes.query {instrument_id: $routeParams.id}

      $q.all([
        $scope.instrument.$promise,
        $scope.code_lists.$promise,
        $scope.categories.$promise,
        $scope.codes.$promise
      ]).then ()->


        get_count_from_used_by = (cl)->
          cl.count = cl.used_by.length
          cl
        $scope.sidebar_objs = (get_count_from_used_by obj for obj in $scope.code_lists)

        for code_list in $scope.code_lists
          CodeResolver.categories $scope, code_list

        if $routeParams.code_list_id?
          $scope.reset()
          $scope.$watch('current.newValue', (newVal, oldVal, scope)->
            console.log newVal, oldVal, scope
            if newVal != oldVal
              if newVal?
                scope.current.codes.push {id: null, value: newVal, category: null, order: null}
                $scope.current.newValue = null
          )

          $scope.breadcrumbs = [
            {label: 'Instruments', link: '/instruments', active: false},
            {label: $scope.instrument.prefix, link: '/instruments/' + $scope.instrument.id.toString(), active: false},
            {label: 'Build', link: '/instruments/' + $scope.instrument.id.toString() + '/build', active: false}
            {label: 'Code Lists', link: false, active: true}
          ]

      $scope.edit_path = (cl)->
        '/instruments/' + $scope.instrument.id + '/build/code_lists/'+ cl.id

      $scope.change_panel = (cl) ->
        $location.url $scope.edit_path cl

      $scope.save = () ->
        angular.copy $scope.current, $scope.code_lists.select_resource_by_id(parseInt($routeParams.code_list_id))
        $scope.code_lists.select_resource_by_id(parseInt($routeParams.code_list_id)).$save(
          {}
        ,(value, rh)->
          value['instrument_id'] = $scope.instrument.id
          value['count'] = value.used_by.length
          Flash.add('success', 'Code list updated successfully!')
          $scope.reset()
        ,->
          console.log("error")
        )

      $scope.removeCode = (code) ->
        $scope.current.codes = (c for c in $scope.current.codes when c.$$hashKey != code.$$hashKey)

      $scope.cancel = () ->
        console.log "cancel called"
        $scope.reset()
        null

      $scope.reset = () ->
        console.log "reset called"
        $scope.current = angular.copy $scope.code_lists.select_resource_by_id parseInt $routeParams.code_list_id
        $scope.editMode = false
        null

      $scope.startEditMode = () ->
        $scope.editMode = true
        null
  ])

build.directive('resumeScroll', ['$timeout', ($timeout)->
  {
    scope:
      key: '@'

    link:
      postLink: (scope, iElement, iAttrs)->
        $timeout ()->
          console.log(scope)
          iElement.scrollTop = localStorage.getItem 'sidebar-scroll-top'
          localStorage.removeItem 'sidebar-scroll-top'

        scope.$on '$destroy', ()->
          localStorage.setItem 'sidebar-scroll-top', iElement.scrollTop
  }
])