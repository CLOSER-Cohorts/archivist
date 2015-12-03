Archivist.Views.ResponseDomainTexts ||= {}

class Archivist.Views.ResponseDomainTexts.IndexView extends Backbone.View
  template: JST["backbone/templates/response_domain_texts/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (responseDomainText) =>
    view = new Archivist.Views.ResponseDomainTexts.ResponseDomainTextView({model : responseDomainText})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(responseDomainTexts: @collection.toJSON() ))
    @addAll()

    return this
