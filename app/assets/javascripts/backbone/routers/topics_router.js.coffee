class Archivist.Routers.TopicsRouter extends Backbone.Router
  initialize: (options) ->
    @topics = new Archivist.Collections.TopicsCollection()
    @topics.reset options.topics

  routes:
    "new"      : "newTopic"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newTopic: ->
    @view = new Archivist.Views.Topics.NewView(collection: @topics)
    $("#topics").html(@view.render().el)

  index: ->
    @view = new Archivist.Views.Topics.IndexView(collection: @topics)
    $("#topics").html(@view.render().el)

  show: (id) ->
    topic = @topics.get(id)

    @view = new Archivist.Views.Topics.ShowView(model: topic)
    $("#topics").html(@view.render().el)

  edit: (id) ->
    topic = @topics.get(id)

    @view = new Archivist.Views.Topics.EditView(model: topic)
    $("#topics").html(@view.render().el)
