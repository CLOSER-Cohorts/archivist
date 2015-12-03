class Archivist.Routers.CcSequencesRouter extends Backbone.Router
  initialize: (options) ->
    @ccSequences = new Archivist.Collections.CcSequencesCollection()
    @ccSequences.reset options.ccSequences

  routes:
    "new"      : "newCcSequence"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newCcSequence: ->
    @view = new Archivist.Views.CcSequences.NewView(collection: @cc_sequences)
    $("#cc_sequences").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.CcSequences.IndexView(collection: @cc_sequences)
    $("#cc_sequences").html(@view.render().el)

  show: (id) ->
    cc_sequence = @cc_sequences.get(id)

    @view = new Archivist.Views.CcSequences.ShowView(model: cc_sequence)
    $("#cc_sequences").html(@view.render().el)

  edit: (id) ->
    cc_sequence = @cc_sequences.get(id)

    @view = new Archivist.Views.CcSequences.EditView(model: cc_sequence)
    $("#cc_sequences").html(@view.render().el)
