define [
  'compiled/backbone-ext/Backbone'
], (Backbone) ->

  class Entry extends Backbone.Model

    defaults:
      id: null
      parent_id: null
      summary: ''
      user_id: null
      replies: []
      posted_at: "2012-03-05T22:46:08Z"

      collapsedView: true
      attachments: false
      outOfContext: false

    attributeMethods:
      author: null

    author: ->
      author = DISCUSSION.participants.get @get 'user_id'
      author.toJSON()

