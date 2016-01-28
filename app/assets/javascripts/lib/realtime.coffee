realtime = angular.module('archivist.realtime', [
])

realtime.factory('RealTimeConnection',
  [
    '$rootScope',
    ($rootScope)->
      service = {}

      service.socket = io window.socket_url

      service.socket.on 'disconnect', ()->
        console.error 'Archivisit RealTime connection lost.'

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
              callback event, message
          );

      listener.prototype.stop = ()->
        @handler()

      (callback) ->
        new listener($rootScope, callback)
  ]
)
