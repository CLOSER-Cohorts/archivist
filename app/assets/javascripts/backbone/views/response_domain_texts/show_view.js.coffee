Archivist.Views.ResponseDomainTexts ||= {}

class Archivist.Views.ResponseDomainTexts.ShowView extends Backbone.View
  template: JST["backbone/templates/response_domain_texts/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
