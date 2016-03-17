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
    .when('/instruments/:id/build/constructs',
      templateUrl: 'partials/build/editor.html'
      controller: 'BuildConstructsController'
      reloadOnSearch: false
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

build.controller('BaseBuildController',[
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
])

build.controller('BuildCodeListsController',
  [
    '$scope'
    '$routeParams',
    '$q',
    '$injector',
    '$location',
    'Flash',
    'Instruments',
    'CodeListsArchive',
    'CategoriesArchive',
    'CodeResolver',
    'RealTimeLocking',
    ($scope, $routeParams, $q, $injector, $location, Flash, Instruments, CodeLists, Categories, CodeResolver, RealTimeLocking)->

      $injector.invoke Toolbox, this, {$scope: $scope, title: "Code Lists"}

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

      $scope.reset = () ->
        console.log "reset called"
        $scope.current = angular.copy $scope.code_lists.select_resource_by_id parseInt $routeParams.code_list_id
        $scope.editMode = false
        RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
        null
  ])

build.controller('BuildResponseDomainsController',
  [
    '$controller',
    '$scope',
    '$routeParams',
    '$location',
    '$filter',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    ($controller, $scope, $routeParams, $location, $filter, Flash, DataManager, RealTimeListener, RealTimeLocking)->

      $scope.title = 'Response Domains'
      $scope.extra_url_parameters = [
        'response_domains'
      ]
      $scope.instrument_options = {
        rds: true
      }

      $scope.reset = ->
        if $routeParams.response_domain_type? and $routeParams.response_domain_id?
          for rd in $scope.instrument.ResponseDomains
            if rd.type.camel_case_to_underscore() + 's' == $routeParams.response_domain_type and rd.id.toString() == $routeParams.response_domain_id

              $scope.current = angular.copy rd
              $scope.editMode = false
              break

        null

      $scope.after_instrument_loaded = ->
        $scope.sidebar_objs = $filter('excludeRDC')($scope.instrument.ResponseDomains)

      $controller(
        'BaseBuildController',
        {
          $scope: $scope,
          $routeParams: $routeParams,
          $location: $location,
          Flash: Flash,
          DataManager: DataManager,
          RealTimeListener: RealTimeListener,
          RealTimeLocking: RealTimeLocking
        }
      )
  ]
)

build.controller('BuildQuestionsController',
  [
    '$scope',
    '$routeParams',
    '$location',
    '$injector',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    (
      $scope,
      $routeParams,
      $location,
      $injector,
      Flash,
      DataManager,
      RealTimeListener,
      RealTimeLocking
    ) ->

      $injector.invoke(
        Toolbox,
        this,
        {
          $scope: $scope,
          DataManager: DataManager,
          title: "Questions",
          extra_url_parameters: [
            'questions'
          ],
          instrument_options: {
            questions: true,
            rds: true
          }
        }
      )

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

      $scope.save = () ->
        if $routeParams.question_type == 'question_items'
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


      $scope.reset = () ->
        console.log "reset called"
        if $routeParams.question_type == 'question_items'
          $scope.current = angular.copy $scope.instrument.Questions.Items.select_resource_by_id parseInt $routeParams.question_id
          $scope.title = 'Question Item'
        else
          $scope.current = angular.copy $scope.instrument.Questions.Grids.select_resource_by_id parseInt $routeParams.question_id
          $scope.title = 'Question Grid'
        $scope.editMode = false
        RealTimeLocking.unlock({type: $scope.current.type, id: $scope.current.id})
        null

  ]
)

build.controller('BuildConstructsController',
  [
    '$controller',
    '$scope',
    '$routeParams',
    '$location',
    '$filter',
    '$http',
    'Flash',
    'DataManager',
    'RealTimeListener',
    'RealTimeLocking',
    ($controller, $scope, $routeParams, $location, $filter, $http, Flash, DataManager, RealTimeListener, RealTimeLocking)->
      console.time 'end to end'
      $scope.title = 'Constructs'
      $scope.overview = true
      $scope.hide_edit_buttons = true
      $scope.extra_url_parameters = [
        'constructs'
      ]
      $scope.instrument_options = {
        constructs: true
        questions: true
      }

      $scope.$on '$routeUpdate', (scope, next, current) ->
        $scope.reset()

      $scope.change_panel = (obj)->
        $location.search {construct_type: obj.type, construct_id: obj.id}

      $scope.sortableOptions = {
        placeholder: 'a-construct',
        connectWith: '.a-construct-container',
        stop: (e, ui)->
          updates = []
          positionUpdater = (parent)->
            child_dimensions = ['children', 'fchildren']
            for dimension, index in child_dimensions
              if parent[dimension]?
                for child_key of parent[dimension]
                  if parent[dimension].hasOwnProperty child_key
                    console.log parent[dimension][child_key].branch
                    if parent[dimension][child_key].position != (parseInt child_key) + 1 or parent[dimension][child_key].parent != parent.id or parent[dimension][child_key].branch != index
                      updates.push {
                        id: parent[dimension][child_key].id,
                        type: parent[dimension][child_key].type,
                        position: (parseInt child_key) + 1,
                        parent: {id: parent.id, type: parent.type},
                        branch: index
                      }
                      parent[dimension][child_key].position = updates[updates.length-1]['position']
                      parent[dimension][child_key].parent = updates[updates.length-1]['parent']
                    positionUpdater parent[dimension][child_key]

          positionUpdater $scope.instrument.topsequence
          $http.post '/instruments/' + $scope.instrument.id.toString() + '/reorder_ccs.json', updates: updates
      }

      $scope.reset = ->
        console.time 'reset'
        console.log $routeParams
        if $routeParams.construct_type? and $routeParams.construct_id?
          for cc in $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's']
            if cc.type.camel_case_to_underscore() == $routeParams.construct_type and cc.id.toString() == $routeParams.construct_id.toString()

              $scope.current = angular.copy cc
              $scope.editMode = false
              break

        if $scope.current?
          $scope.details = {fields: []}
          for key of $scope.current
            if ['label', 'literal'].indexOf(key) >= 0
              $scope.details.fields.splice 0, 0, {label: key.capitalizeFirstLetter(), model: $scope.current[key]}

          if $scope.current.type == 'question'
            $scope.details.fields.push {
              label: 'Type',
              model: $scope.current.question_type,
              options:[
                {value: 'QuestionItem', label: 'Item'},
                {value: 'QuestionGrid', label: 'Grid'}
              ]
            }
            $scope.details.fields.push {
              label: 'Question',
              model: $scope.current.question_id,
              options: if $scope.current.question_type == 'QuestionItem' then DataManager.getQuestionItemIDs() else DataManager.getQuestionGridIDs()
            }
            DataManager.getResponseUnits $scope.instrument.id, false, ()->
              options = []
              for ru in DataManager.Data.ResponseUnits[$scope.instrument.id]
                options.push {value: ru.id, label: ru.label}
              $scope.details.fields.push {
                label: 'Interviewee',
                model: $scope.current.response_unit_id,
                options: options
              }

        console.timeEnd 'reset'
        null

      $scope.after_instrument_loaded = ->
        console.time 'after instrument'
        constructSorter = (a, b)->
          a.position > b.position
        if !DataManager.ConstructResolver?
          DataManager.resolveConstructs()
          DataManager.resolveQuestions()
          sortChildren = (parent)->
            if parent.children?
              parent.children.sort constructSorter
              for child in parent.children
                sortChildren child
              if parent.fchildren?
                parent.fchildren.sort constructSorter
                for child in parent.fchildren
                  sortChildren child
          sortChildren $scope.instrument.topsequence

        console.timeEnd 'after instrument'
        console.timeEnd 'end to end'

      $scope.new = ->
        $location.search {construct_type: null, construct_id: null}
        $scope.current = {}
        $scope.details = {fields: []}
        $scope.details.fields.push {
          label: 'Construct',
          model: $scope.current.construct_type,
          options:[
            {value: 'condition', label: 'Condition'},
            {value: 'loop', label: 'Loop'},
            {value: 'quesiton', label: 'Question'},
            {value: 'sequence', label: 'Sequence'},
            {value: 'statement', label: 'Statement'}
          ]
        }

      console.time 'load base'
      $controller(
        'BaseBuildController',
        {
          $scope: $scope,
          $routeParams: $routeParams,
          $location: $location,
          Flash: Flash,
          DataManager: DataManager,
          RealTimeListener: RealTimeListener,
          RealTimeLocking: RealTimeLocking
        }
      )
      console.timeEnd 'load base'
      console.log $scope
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

build.filter('stripRD', ->
  (item)->
    item.replace 'ResponseDomain', ''
)

build.filter('excludeRDC', ->
  (items)->
    output = []
    angular.forEach items, (item)->
      if item.type != 'ResponseDomainCode'
        output.push item
    output
)