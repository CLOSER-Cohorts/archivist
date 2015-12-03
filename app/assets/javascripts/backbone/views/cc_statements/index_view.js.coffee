Archivist.Views.CcStatements ||= {}

class Archivist.Views.CcStatements.IndexView extends Backbone.View
  template: JST["backbone/templates/cc_statements/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (ccStatement) =>
    view = new Archivist.Views.CcStatements.CcStatementView({model : ccStatement})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(ccStatements: @collection.toJSON() ))
    @addAll()

    return this
