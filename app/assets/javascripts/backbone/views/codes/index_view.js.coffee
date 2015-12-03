Archivist.Views.Codes ||= {}

class Archivist.Views.Codes.IndexView extends Backbone.View
  template: JST["backbone/templates/codes/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (code) =>
    view = new Archivist.Views.Codes.CodeView({model : code})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(codes: @collection.toJSON() ))
    @addAll()

    return this
