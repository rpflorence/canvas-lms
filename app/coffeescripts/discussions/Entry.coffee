define [
  'compiled/backbone-ext/Backbone'
], (Backbone) ->

  class Entry extends Backbone.Model

    defaults:
      id: null
      parent_id: null
      summary: null
      message: null
      user_id: null
      replies: []
      posted_at: "2012-03-05T22:46:08Z"

      collapsedView: true
      attachments: false
      outOfContext: false

    attributeMethods:
      author: null

    url: ->
      id = @get 'id'
      "#{ENV.DISCUSSION.ENTRY_ROOT_URL}?ids[]=#{id}"

    parse: (data) ->
      data[0]

    author: ->
      author = DISCUSSION.participants.get @get 'user_id'
      author.toJSON()

