class Archivist.Models.CodeList extends Backbone.Model
  paramRoot: 'code_list'

  defaults:
    label: null

class Archivist.Collections.CodeListsCollection extends Backbone.Collection
  model: Archivist.Models.CodeList
  url: '/code_lists'
