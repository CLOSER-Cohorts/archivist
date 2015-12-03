class Archivist.Models.Instruction extends Backbone.Model
  paramRoot: 'instruction'

  defaults:
    text: null

class Archivist.Collections.InstructionsCollection extends Backbone.Collection
  model: Archivist.Models.Instruction
  url: '/instructions'
