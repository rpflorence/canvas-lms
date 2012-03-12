define [
  'use!backbone'
  'compiled/discussions/Entry'
], (Backbone, Entry) ->

  class EntryCollection extends Backbone.Collection

    model: Entry

