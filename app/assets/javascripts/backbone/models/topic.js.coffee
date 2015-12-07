class Archivist.Models.Topic extends Backbone.Model
  paramRoot: 'topic'

  defaults:
    name: null
    parent: null
    code: null

class Archivist.Collections.TopicsCollection extends Backbone.Collection
  model: Archivist.Models.Topic
  url: '/topics'
