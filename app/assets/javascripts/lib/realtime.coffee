realtime = angular.module('archivist.realtime', [
  'ngRoute',
  'archivist.flash'
])

realtime.factory('RealTimeConnection',
  [
    '$rootScope',
    '$timeout',
    'Flash'
    ($rootScope, $timeout, Flash)->
      service = {}

      service.socket = io window.socket_url

      service.socket.on 'disconnect', ()->
        $rootScope.$apply ->
          $rootScope.realtimeStatus = false

      service.socket.on 'connect', ()->
        $timeout ->
          $rootScope.realtimeStatus = true

      service.socket.on 'rt-update', (message)->
        $rootScope.$emit('rt-update', message)
      service
  ]
)

realtime.factory('RealTimeListener',
  [
    '$rootScope', '$http'
    ($rootScope, $http)->
      listener = class
        constructor: ($rootScope, callback)->
          @handler = $rootScope.$on('rt-update', (event, message)->
            $rootScope.$apply () ->
              no_more_pending_requests = $rootScope.$watch ->
                $http.pendingRequests.length
              , ->
                if $http.pendingRequests.length < 1
                  callback event, JSON.parse message
                  no_more_pending_requests()
          )

      listener.prototype.stop = ()->
        @handler()

      (callback) ->
        new listener($rootScope, callback)
  ]
)

realtime.factory('RealTimeLocking',
  [
    '$rootScope',
    '$routeParams',
    'RealTimeConnection',
    ($rootScope, $routeParams, RTC)->
      service = {}

      service.locks = []

      service.comparator = {
        CodeList: (id)->
          $routeParams['code_list_id'] == id.toString()
        QuestionItem: (id)->
          $routeParams['question_type'] == 'question-item' and $routeParams['question_id'] == id.toString()
        QuestionGrid: (id)->
          $routeParams['question_type'] == 'question-grid' and $routeParams['question_id'] == id.toString()
      }

      service.lock = (obj) ->
        RTC.socket.emit 'lock', JSON.stringify obj

      service.unlock = (obj) ->
        RTC.socket.emit 'unlock', JSON.stringify obj

      RTC.socket.on 'locks-updated', (message)->
        locks = JSON.parse message
        $('.lockable').prop('disabled', false)
        for lock in locks
          console.log lock
          if service.comparator[lock.type] lock.id
            $('.lockable').prop('disabled', true);

      service
  ]
)