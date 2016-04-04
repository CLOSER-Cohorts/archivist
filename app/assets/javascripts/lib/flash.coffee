flash = angular.module('archivist.flash', ['ngMessages'])

flash.factory('Flash', ['$interval',($interval)->

  LOCAL_STORAGE_KEY = 'notices'

  notices = JSON.parse( localStorage.getItem LOCAL_STORAGE_KEY ) || []

  store = ->
    localStorage.setItem LOCAL_STORAGE_KEY, JSON.stringify notices

  clear = ->
    notices = []
    store()

  {

    add: (type, message) ->
      notices.push({type: type, message: message})
      store()

    publish: (scope) ->
      scope.notices = notices
      clear()

    listen: (scope) ->


    clear: @clear
    store: @store

  }
])