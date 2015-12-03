Archivist.Views.CcConditions ||= {}

class Archivist.Views.CcConditions.CcConditionView extends Backbone.View
  template: JST["backbone/templates/cc_conditions/cc_condition"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
