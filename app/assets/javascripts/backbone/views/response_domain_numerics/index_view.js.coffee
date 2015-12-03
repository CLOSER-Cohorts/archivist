Archivist.Views.ResponseDomainNumerics ||= {}

class Archivist.Views.ResponseDomainNumerics.IndexView extends Backbone.View
  template: JST["backbone/templates/response_domain_numerics/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (responseDomainNumeric) =>
    view = new Archivist.Views.ResponseDomainNumerics.ResponseDomainNumericView({model : responseDomainNumeric})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(responseDomainNumerics: @collection.toJSON() ))
    @addAll()

    return this
