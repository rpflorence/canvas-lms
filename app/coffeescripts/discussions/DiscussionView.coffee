define [
  'use!underscore'
  'compiled/backbone-ext/Backbone'
  'compiled/discussions/EntryCollection'
  'compiled/discussions/EntryCollectionView'
  'compiled/discussions/EntryView'
  'compiled/discussions/ParticipantCollection'
  'jst/discussions/Discussion'
], (_, Backbone, EntryCollection, EntryCollectionView, EntryView, ParticipantCollection, template) ->

  class DiscussionView extends Backbone.View

    events:

      ##
      # catch-all for delegating entry click events in this view instead
      # of delegating events in every entry view
      'click .entry [data-event]': 'handleEntryEvent'

    initialize: ->
      @$el = $ '#content'
      @model.bind 'change:participants', @initParticipants
      @model.bind 'change:view', @initEntries
      @render()

      # kicks it all off
      @model.fetch
        success: @expandUnread

    render: ->
      @$el.html template @model.toJSON()
      super

    initEntries: =>
      console.time 'initEntries'
      $entries = @$ '.discussion-entries'
      @entries = new EntryCollection
      @entriesView = new EntryCollectionView $entries, @entries
      @entries.reset @model.get 'view'
      console.timeEnd 'initEntries'

    initParticipants: =>
      @participants = new ParticipantCollection
      @participants.reset @model.get 'participants'

    expandUnread: =>
      ids = _.map(@model.get('unread_entries'), (id) -> "ids[]=#{id}").join '&'
      url = "#{ENV.DISCUSSION.ENTRY_ROOT_URL}?#{ids}"
      $.getJSON url, (data) ->
        _.each data, (attributes) ->
          view = EntryView.instances[attributes.id]
          view.model.set attributes

    handleEntryEvent: (event) ->
      event.stopPropagation()

      # get the element and the method to call
      el = $ event.currentTarget
      method = el.data 'event'

      # get the EntryView instance ID
      modelEl = el.parents ".#{EntryView::className}:first"
      id = modelEl.data 'id'

      # call the method from the EntryView
      EntryView.instances[id][method] event, el

