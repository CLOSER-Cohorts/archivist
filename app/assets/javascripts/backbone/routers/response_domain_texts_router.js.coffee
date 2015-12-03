class Archivist.Routers.ResponseDomainTextsRouter extends Backbone.Router
  initialize: (options) ->
    @responseDomainTexts = new Archivist.Collections.ResponseDomainTextsCollection()
    @responseDomainTexts.reset options.responseDomainTexts

  routes:
    "new"      : "newResponseDomainText"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newResponseDomainText: ->
    @view = new Archivist.Views.ResponseDomainTexts.NewView(collection: @response_domain_texts)
    $("#response_domain_texts").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.ResponseDomainTexts.IndexView(collection: @response_domain_texts)
    $("#response_domain_texts").html(@view.render().el)

  show: (id) ->
    response_domain_text = @response_domain_texts.get(id)

    @view = new Archivist.Views.ResponseDomainTexts.ShowView(model: response_domain_text)
    $("#response_domain_texts").html(@view.render().el)

  edit: (id) ->
    response_domain_text = @response_domain_texts.get(id)

    @view = new Archivist.Views.ResponseDomainTexts.EditView(model: response_domain_text)
    $("#response_domain_texts").html(@view.render().el)
