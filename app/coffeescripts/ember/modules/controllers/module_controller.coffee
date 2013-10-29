define [
  'ember',
  'jquery',
  '../../shared/xhr/parse_link_header'
], ({ObjectController, get, set}, $, parseLinkHeader) ->

  ModuleController = ObjectController.extend

    actions:

      loadNextItems: ->
        @loadItems get(this, 'itemLinks.next')

      addModuleItem: ->
        @get('items').pushObject
          title: "new guy"

    loadItems: (url) ->
      set this, 'isLoading', true
      $.getJSON url, (items, status, xhr) =>
        set this, 'isLoading', false
        set this, 'itemLinks', parseLinkHeader(xhr)
        @get('items').pushObjects items

    loadPagedItems: (->
      items = get this, 'items'
      return if items
      set this, 'items', []
      @loadItems get(this, 'items_url')
    ).on('init')

