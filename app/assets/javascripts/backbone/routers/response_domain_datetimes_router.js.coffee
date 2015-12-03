class Archivist.Routers.ResponseDomainDatetimesRouter extends Backbone.Router
  initialize: (options) ->
    @responseDomainDatetimes = new Archivist.Collections.ResponseDomainDatetimesCollection()
    @responseDomainDatetimes.reset options.responseDomainDatetimes

  routes:
    "new"      : "newResponseDomainDatetime"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newResponseDomainDatetime: ->
    @view = new Archivist.Views.ResponseDomainDatetimes.NewView(collection: @response_domain_datetimes)
    $("#response_domain_datetimes").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.ResponseDomainDatetimes.IndexView(collection: @response_domain_datetimes)
    $("#response_domain_datetimes").html(@view.render().el)

  show: (id) ->
    response_domain_datetime = @response_domain_datetimes.get(id)

    @view = new Archivist.Views.ResponseDomainDatetimes.ShowView(model: response_domain_datetime)
    $("#response_domain_datetimes").html(@view.render().el)

  edit: (id) ->
    response_domain_datetime = @response_domain_datetimes.get(id)

    @view = new Archivist.Views.ResponseDomainDatetimes.EditView(model: response_domain_datetime)
    $("#response_domain_datetimes").html(@view.render().el)
