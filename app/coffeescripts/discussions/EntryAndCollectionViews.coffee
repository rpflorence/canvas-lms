define [
  'use!backbone'
  'compiled/discussions/EntryCollection'
  'jst/discussions/_entry_content'
  'jst/discussions/entry_with_replies'
], (Backbone, EntryCollection, entryContentPartial, entryWithRepliesTemplate) ->

  # EntryView and EntryCollectionView depend on each other, so we define
  # them in the same module to avoid circular dependency tricks

  # save memory
  noop = ->

  ##
  # View for a single entry
  class EntryView extends Backbone.View

    # So we can delegate from DiscussionView, instead of attaching
    # handlers for every EntryView, and then stopping propagation since
    # they're nested.
    @instances = []

    tagName: 'li'

    className: 'entry'

    initialize: ->
      super
      @render()

      id = @model.get 'id'

      # store the instance so we can delegate from DiscussionView
      EntryView.instances[id] = this

      # for event handler delegated from DiscussionView
      @$el.attr 'data-id', id

      @createReplies() if @model.get('replies').length

    remove: ->
      @$el.children('.author').html ''
      @$el.children('.summary').html '<p>[deleted]</p>'

    fetchFullEntry: ->
      @model.fetch()
      # only fetch once
      @fetchFullEntry = noop

    render: ->
      @$el.html entryWithRepliesTemplate @model.toJSON()
      super

    createReplies: ->
      el = @$el.find '.replies'
      @collection = new EntryCollection
      @view = new EntryCollectionView el, @collection
      @collection.reset @model.get('replies')


  ##
  # View for a collection of entries
  class EntryCollectionView extends Backbone.View

    initialize: (@$el, @entries, args...) ->
      super args...
      @entries.bind 'reset', @addAll
      @entries.bind 'add', @add
      @render()

    render: ->
      @$el.html '<ul class=discussion-entries></ul>'
      @cacheElements()

    cacheElements: ->
      @list = @$el.children '.discussion-entries'

    add: (entry) =>
      view = new EntryView model: entry
      @list.append view.el

    addAll: =>
      @entries.each @add

  ##
  # Export the modules
  {EntryView, EntryCollectionView}

