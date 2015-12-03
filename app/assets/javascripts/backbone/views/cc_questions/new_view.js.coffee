Archivist.Views.CcQuestions ||= {}

class Archivist.Views.CcQuestions.NewView extends Backbone.View
  template: JST["backbone/templates/cc_questions/new"]

  events:
    "submit #new-cc_question": "save"

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
      success: (cc_question) =>
        @model = cc_question
        window.location.hash = "/#{@model.id}"

      error: (cc_question, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
