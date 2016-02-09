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
      @actions = {save: {method: 'PUT'}}

    @index = (method, parameters)->
      path + method + JSON.stringify parameters

    @resource = $resource(
      path,
      paramDefaults,
      @actions,
      options
    )

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

    this
])