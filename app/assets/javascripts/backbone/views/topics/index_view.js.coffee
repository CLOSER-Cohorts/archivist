Archivist.Views.Topics ||= {}

class Archivist.Views.Topics.IndexView extends Backbone.View
  template: JST["backbone/templates/topics/index"]

  initialize: () ->
    @collection.bind('reset', @addAll)

  addAll: () =>
    @collection.each(@addOne)

  addOne: (topic) =>
    view = new Archivist.Views.Topics.TopicView({model : topic})
    @$("tbody").append(view.render().el)

  render: =>
    @$el.html(@template(topics: @collection.toJSON() ))
    @addAll()

    return this
