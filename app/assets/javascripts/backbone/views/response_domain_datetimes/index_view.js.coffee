Archivist.Views.ResponseDomainDatetimes ||= {}

class Archivist.Views.ResponseDomainDatetimes.IndexView extends Backbone.View
  template: JST["backbone/templates/response_domain_datetimes/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (responseDomainDatetime) =>
    view = new Archivist.Views.ResponseDomainDatetimes.ResponseDomainDatetimeView({model : responseDomainDatetime})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(responseDomainDatetimes: @collection.toJSON() ))
    @addAll()

    return this
