resource = angular.module('archivist.resource', [
  'ngResource',
])

resource.factory('WrappedResource', [ '$resource', ($resource)->
  (path, paramDefaults, actions, options) ->
    that = this
    @data =  {}

    if actions?
     @actions = actions
    else
      @actions = {save: {method: 'PUT'}, create: {method: 'POST'}}

    @index = (method, parameters)->
      path + method + JSON.stringify parameters

    @resource = $resource(
      path,
      paramDefaults,
      @actions,
      options
    )

    @resource::save = (params, success, error)->
      console.trace()
      if @id?
        @$save(params, success, error)
      else
        @$create(params, success, error)

    @query = (parameters, success, error)->
      if not that.data[@index 'query', parameters]?
        that.data[@index 'query', parameters] = that.resource.query parameters
        , (value, responseHeaders)->
            for obj in value
              for k, v of parameters
                obj[k] = v

            if success?
              success value, responseHeaders
        , error

      that.data[@index 'query', parameters]

    @requery = (parameters, success, error)->
      that.data[@index 'query', parameters] = null
      that.query(parameters, success, error)

    @get = (parameters, success, error)->
      if not that.data[@index 'get', parameters]?
        that.data[@index 'get', parameters] = that.resource.get(parameters, success, error)
      that.data[@index 'get', parameters]

    @reget = (parameters, success, error)->
      that.data[@index 'get', parameters] = null
      that.get(parameters, success, error)

    @clearCache = ->
      that.data = {}

    this
])

resource.factory('GetResource', [
  '$http',
  ($http)->
    (url, isArray = false, cb)->
      if isArray
        rsrc = []
      else
        rsrc = {}

      rsrc.$resolved = false
      rsrc.$promise = $http.get(url, {cache: true})
      sub_promise = rsrc.$promise.then(
        (res)->
          for key of res.data
            if res.data.hasOwnProperty key
              rsrc[key] = res.data[key]
          rsrc.$resolved = true
      )
      sub_promise.then(cb) if typeof cb is 'function'
      rsrc
])
