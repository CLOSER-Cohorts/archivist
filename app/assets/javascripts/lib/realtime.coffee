realtime = angular.module('archivist.realtime', [
  'ngRoute',
  'archivist.flash'
])

realtime.factory('RealTimeConnection',
  [
    '$rootScope',
    'Flash'
    ($rootScope, Flash)->
      service = {}

      service.socket = io window.socket_url

      service.socket.on 'disconnect', ()->
        $rootScope.$apply ->
          $rootScope.realtimeStatus = false

      service.socket.on 'connect', ()->
        $rootScope.$apply ->
          $rootScope.realtimeStatus = true

      service.socket.on 'rt-update', (message)->
        $rootScope.$emit('rt-update', message)
      service
  ]
)

realtime.factory('RealTimeListener',
  [
    '$rootScope',
    ($rootScope)->
      listener = class
        constructor: ($rootScope, callback)->
          @handler = $rootScope.$on('rt-update', (event, message)->
            $rootScope.$apply () ->
              callback event, JSON.parse message
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