Archivist.Views.CcConditions ||= {}

class Archivist.Views.CcConditions.ShowView extends Backbone.View
  template: JST["backbone/templates/cc_conditions/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
