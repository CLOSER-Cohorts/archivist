Archivist.Views.CodeLists ||= {}

class Archivist.Views.CodeLists.EditView extends Backbone.View
  template: JST["backbone/templates/code_lists/edit"]

  events:
    "submit #edit-code_list": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (code_list) =>
        @model = code_list
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
