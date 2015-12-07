Archivist.Views.Variables ||= {}

class Archivist.Views.Variables.IndexView extends Backbone.View
  template: JST["backbone/templates/variables/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (variable) =>
    view = new Archivist.Views.Variables.VariableView({model : variable})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(variables: @collection.toJSON() ))
    @addAll()

    return this
