class Archivist.Routers.ResponseDomainCodesRouter extends Backbone.Router
  initialize: (options) ->
    @responseDomainCodes = new Archivist.Collections.ResponseDomainCodesCollection()
    @responseDomainCodes.reset options.responseDomainCodes

  routes:
    "new"      : "newResponseDomainCode"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newResponseDomainCode: ->
    @view = new Archivist.Views.ResponseDomainCodes.NewView(collection: @response_domain_codes)
    $("#response_domain_codes").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.ResponseDomainCodes.IndexView(collection: @response_domain_codes)
    $("#response_domain_codes").html(@view.render().el)

  show: (id) ->
    response_domain_code = @response_domain_codes.get(id)

    @view = new Archivist.Views.ResponseDomainCodes.ShowView(model: response_domain_code)
    $("#response_domain_codes").html(@view.render().el)

  edit: (id) ->
    response_domain_code = @response_domain_codes.get(id)

    @view = new Archivist.Views.ResponseDomainCodes.EditView(model: response_domain_code)
    $("#response_domain_codes").html(@view.render().el)
