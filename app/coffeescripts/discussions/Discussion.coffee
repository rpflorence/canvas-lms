define [
  'compiled/backbone-ext/Backbone'
], (Backbone) ->

  class Discussion extends Backbone.Model

    defaults:
      participants: []
      unread_entries: []
      view: []

    attributeMethods:
      unreadCount: ['unread_entries']

    url: ENV.DISCUSSION.ROOT_URL

    unreadCount: ->
      @get('unread_entries').length

    # debugging only, remove
    parse: (data) ->
      console.log data
      data

