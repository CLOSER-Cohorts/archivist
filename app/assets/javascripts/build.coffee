build = angular.module('archivist.build', [
  'templates',
  'ngRoute',
  'archivist.flash',
  'archivist.instruments',
  'archivist.code_lists',
  'archivist.categories',
  'archivist.codes',
  'archivist.data_manager',
  'archivist.realtime'
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
      templateUrl: 'partials/build/editor.html'
      controller: 'BuildCodeListsController'
    )
    .when('/instruments/:id/build/response_domains/:response_domain_type?/:response_domain_id?',
      templateUrl: 'partials/build/editor.html'
      controller: 'BuildResponseDomainsController'
    )
    .when('/instruments/:id/build/questions/:question_type?/:question_id?',
      templateUrl: 'partials/build/editor.html'
      controller: 'BuildQuestionsController'
    )
    .when('/instruments/:id/build/constructs/:construct_type?/:construct_id?',
      templateUrl: 'partials/build/editor.html'
      controller: 'BuildConstructsController'
    )
])

build.controller('BuildMenuController',
  [
    '$scope',
    '$routeParams',
    ($scope, $routeParams)->
      $scope.code_lists_url = '/instruments/' + $routeParams.id + '/build/code_lists'
      $scope.response_domains_url = '/instruments/' + $routeParams.id + '/build/response_domains'
      $scope.questions_url = '/instruments/' + $routeParams.id + '/build/questions'
      $scope.constructs_url = '/instruments/' + $routeParams.id + '/build/constructs'
  ])

build.controller('BuildCodeListsController',
  [
    '$scope'
    '$routeParams',
    '$q',
    '$location',
    'Flash',
    'Instruments',
    'CodeListsArchive',
    'CategoriesArchive',
    'CodeResolver',
    'RealTimeLocking',
    ($scope, $routeParams, $q, $location, Flash, Instruments, CodeLists, Categories, CodeResolver, RealTimeLocking)->

      $scope.title = "Code lists"
      $scope.main_panel = "partials/build/code_lists.html"
      $scope.page['title'] = 'Code Lists'

      $scope.instrument = Instruments.get {id: $routeParams.id}, ->
        $scope.page['title'] = $scope.instrument.prefix + ' | Code Lists'
      $scope.code_lists = CodeLists.query {instrument_id: $routeParams.id}
      $scope.categories = Categories.query {instrument_id: $routeParams.id}

      $q.all([
        $scope.instrument.$promise,
        $scope.code_lists.$promise,
        $scope.categories.$promise
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
        RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
        null

      $scope.startEditMode = () ->
        $scope.editMode = true
        console.log $scope.current
        RealTimeLocking.lock({type: $scope.current.type, id: $scope.current.id})
        null
  ])

build.controller('BuildResponseDomainsController',
  [
    '$scope',
    '$routeParams',
    ($scope, $routeParams)->
      $scope.title = "Response Domains"
      $scope.main_panel = "partials/build/response_domains.html"
      $scope.page['title'] = 'Response Domains'
  ]
)

build.controller('BuildQuestionsController',
  [
    '$scope',
    '$routeParams',
    '$location',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    (
      $scope,
      $routeParams,
      $location,
      Flash,
      DataManager,
      RealTimeListener,
      RealTimeLocking
    ) ->
      $scope.title = "Questions"
      $scope.main_panel = 'partials/build/questions.html'
      $scope.page['title'] = 'Questions'

      $scope.instrument = DataManager.getInstrument($routeParams.id,{questions: true, rds: true}, ()->
        $scope.page['title'] = $scope.instrument.prefix + ' | Questions'
        $scope.sidebar_objs =  $scope.instrument.Questions.Items.concat $scope.instrument.Questions.Grids
        if $routeParams.question_id?
          $scope.reset()

          $scope.breadcrumbs = [
            {label: 'Instruments', link: '/instruments', active: false},
            {label: $scope.instrument.prefix, link: '/instruments/' + $scope.instrument.id.toString(), active: false},
            {label: 'Build', link: '/instruments/' + $scope.instrument.id.toString() + '/build', active: false}
            {label: 'Questions', link: false, active: true}
          ]
      )

      $scope.listener = RealTimeListener (event, message)->
        if !$scope.editMode
          $scope.reset()

      $scope.save = () ->
        if $routeParams.question_type == 'question-item'
          angular.copy $scope.current, $scope.instrument.Questions.Items.select_resource_by_id(parseInt($routeParams.question_id))
          $scope.instrument.Questions.Items.select_resource_by_id(parseInt($routeParams.question_id)).$save(
            {}
          ,(value, rh)->
            value['instrument_id'] = $scope.instrument.id
            Flash.add('success', 'Question updated successfully!')
            $scope.reset()
          ,->
            console.log("error")
          )

      $scope.cancel = () ->
        console.log "cancel called"
        $scope.reset()
        null

      $scope.edit_path = (q)->
        '/instruments/' +
          $scope.instrument.id +
          '/build/questions/' +
          q.type.replace(/([A-Z])/g, (x,y) -> "-"+y.toLowerCase()).replace /^-/, '' +
          '/' +
          q.id

      $scope.change_panel = (q) ->
        $location.url $scope.edit_path q

      $scope.reset = () ->
        console.log "reset called"
        if $routeParams.question_type == 'question-item'
          $scope.current = angular.copy $scope.instrument.Questions.Items.select_resource_by_id parseInt $routeParams.question_id
          $scope.title = 'Question Item'
        else
          $scope.current = angular.copy $scope.instrument.Questions.Grids.select_resource_by_id parseInt $routeParams.question_id
          $scope.title = 'Question Grid'
        $scope.editMode = false
        RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
        null

      $scope.startEditMode = () ->
        $scope.editMode = true
        RealTimeLocking.lock({type: $scope.current.type, id: $scope.current.id})
        null
  ]
)

build.controller('BuildConstructsController',
  [
    '$scope',
    '$routeParams',
    ($scope, $routeParams)->
      $scope.title = "Constructs"
      $scope.main_panel = "partials/build/constructs.html"
      $scope.page['title'] = 'Constructs'
  ]
)

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

build.directive('strip', [ ->
  {
  scope:
    key: '@'

  link:
    postLink: (scope, iElement, iAttrs)->
      iElement.text = iElement.text.replaceAll 'ResponseDomain', ''
  }
])