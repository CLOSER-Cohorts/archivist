class Archivist.Routers.InstrumentsRouter extends Backbone.Router
  initialize: (options) ->
    @instruments = new Archivist.Collections.InstrumentsCollection()
    @instruments.reset options.instruments

  routes:
    "new"      : "newInstrument"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newInstrument: ->
    @view = new Archivist.Views.Instruments.NewView(collection: @instruments)
    $("#instruments").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.Instruments.IndexView(collection: @instruments)
    $("#instruments").html(@view.render().el)

  show: (id) ->
    instrument = @instruments.get(id)

    @view = new Archivist.Views.Instruments.ShowView(model: instrument)
    $("#instruments").html(@view.render().el)

  edit: (id) ->
    instrument = @instruments.get(id)

    @view = new Archivist.Views.Instruments.EditView(model: instrument)
    $("#instruments").html(@view.render().el)
