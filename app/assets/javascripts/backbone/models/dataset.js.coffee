class Archivist.Models.Dataset extends Backbone.Model
  paramRoot: 'dataset'

  defaults:
    name: null

class Archivist.Collections.DatasetsCollection extends Backbone.Collection
  model: Archivist.Models.Dataset
  url: '/datasets'
