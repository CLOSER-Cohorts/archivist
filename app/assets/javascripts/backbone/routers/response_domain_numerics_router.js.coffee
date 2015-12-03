class Archivist.Routers.ResponseDomainNumericsRouter extends Backbone.Router
  initialize: (options) ->
    @responseDomainNumerics = new Archivist.Collections.ResponseDomainNumericsCollection()
    @responseDomainNumerics.reset options.responseDomainNumerics

  routes:
    "new"      : "newResponseDomainNumeric"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newResponseDomainNumeric: ->
    @view = new Archivist.Views.ResponseDomainNumerics.NewView(collection: @response_domain_numerics)
    $("#response_domain_numerics").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.ResponseDomainNumerics.IndexView(collection: @response_domain_numerics)
    $("#response_domain_numerics").html(@view.render().el)

  show: (id) ->
    response_domain_numeric = @response_domain_numerics.get(id)

    @view = new Archivist.Views.ResponseDomainNumerics.ShowView(model: response_domain_numeric)
    $("#response_domain_numerics").html(@view.render().el)

  edit: (id) ->
    response_domain_numeric = @response_domain_numerics.get(id)

    @view = new Archivist.Views.ResponseDomainNumerics.EditView(model: response_domain_numeric)
    $("#response_domain_numerics").html(@view.render().el)
