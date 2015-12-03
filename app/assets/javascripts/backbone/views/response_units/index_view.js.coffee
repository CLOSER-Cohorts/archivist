Archivist.Views.ResponseUnits ||= {}

class Archivist.Views.ResponseUnits.IndexView extends Backbone.View
  template: JST["backbone/templates/response_units/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (responseUnit) =>
    view = new Archivist.Views.ResponseUnits.ResponseUnitView({model : responseUnit})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(responseUnits: @collection.toJSON() ))
    @addAll()

    return this
