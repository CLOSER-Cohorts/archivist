Archivist.Views.CodeLists ||= {}

class Archivist.Views.CodeLists.NewView extends Backbone.View
  template: JST["backbone/templates/code_lists/new"]

  events:
    "submit #new-code_list": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (code_list) =>
        @model = code_list
        window.location.hash = "/#{@model.id}"

      error: (code_list, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
