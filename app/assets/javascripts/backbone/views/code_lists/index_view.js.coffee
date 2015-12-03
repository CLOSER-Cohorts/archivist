Archivist.Views.CodeLists ||= {}

class Archivist.Views.CodeLists.IndexView extends Backbone.View
  template: JST["backbone/templates/code_lists/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (codeList) =>
    view = new Archivist.Views.CodeLists.CodeListView({model : codeList})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(codeLists: @collection.toJSON() ))
    @addAll()

    return this
