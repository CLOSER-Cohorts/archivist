Archivist.Views.ResponseDomainCodes ||= {}

class Archivist.Views.ResponseDomainCodes.IndexView extends Backbone.View
  template: JST["backbone/templates/response_domain_codes/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (responseDomainCode) =>
    view = new Archivist.Views.ResponseDomainCodes.ResponseDomainCodeView({model : responseDomainCode})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(responseDomainCodes: @collection.toJSON() ))
    @addAll()

    return this
