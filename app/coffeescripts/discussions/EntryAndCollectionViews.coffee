define [
  'use!backbone'
  'compiled/discussions/EntryCollection'
  'jst/discussions/_entry_content'
  'jst/discussions/entry_with_replies'
  'jquery.disableWhileLoading'
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

      # store the instance so we can delegate from DiscussionView
      id = @model.get 'id'
      EntryView.instances[id] = this

      # for event handler delegated from DiscussionView
      @$el.attr 'data-id', id

      @model.bind 'change:collapsedView', @onCollapsedView
      @toggleCollapsedClass()

      @createReplies() if @model.get('replies').length

    remove: ->

    toggleCollapsed: ->
      @model.set 'collapsedView', !@model.get('collapsedView')

    onCollapsedView: (model, collapsedView) =>
      unless collapsedView and @model.get 'message'
        @model.set 'message', @model.get 'summary'
        req = @model.fetch()
        #@$('.entry_content:first .message').disableWhileLoading req

      @toggleCollapsedClass()

    toggleCollapsedClass: ->
      collapsedView = @model.get 'collapsedView'
      @$el
        .toggleClass('collapsed', collapsedView)
        .toggleClass('expanded', !collapsedView)

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

