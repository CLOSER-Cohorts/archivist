Archivist.Views.CcConditions ||= {}

class Archivist.Views.CcConditions.IndexView extends Backbone.View
  template: JST["backbone/templates/cc_conditions/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (ccCondition) =>
    view = new Archivist.Views.CcConditions.CcConditionView({model : ccCondition})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(ccConditions: @collection.toJSON() ))
    @addAll()

    return this
