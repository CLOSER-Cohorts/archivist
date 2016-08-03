flash = angular.module('archivist.flash', ['ngMessages'])

flash.factory('Flash', ['$interval',($interval)->

  LOCAL_STORAGE_KEY = 'notices'

  notices = JSON.parse( localStorage.getItem LOCAL_STORAGE_KEY ) || []
  scope = null

  store = ->
    localStorage.setItem LOCAL_STORAGE_KEY, JSON.stringify notices

  clear = ->
    notices = []
    store()

  {

    add: (type, message) ->
      notices.push({type: type, message: message})
      store()

      if document.getElementsByTagName LOCAL_STORAGE_KEY
        @publish(scope)

    publish: (_scope) ->
      _scope.notices = notices
      clear()


    set_scope: (_scope) ->
      scope = _scope

    listen: (scope) ->


    clear: @clear
    store: @store

  }
])