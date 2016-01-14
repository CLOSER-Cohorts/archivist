flash = angular.module('archivist.flash', ['ngMessages'])

flash.factory('flash', ['$interval',($interval)->

  notices = []

  clear = ->
    notices = []

  {
    add: (type, message) ->
      notices.push({type: type, message: message})

    publish: (scope) ->
      scope.notices = notices
      clear()

    clear: @clear
  }
])