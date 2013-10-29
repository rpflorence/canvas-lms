define ['ember', 'jquery', 'underscore'], (Ember, $, {throttle}) ->

  # prime candidate for a shared view, next time we do something like this

  $window = $ window

  ModuleView = Ember.View.extend

    register: (->
      if @get 'controller.itemLinks.next'
        @constructor.register this
    ).observes('controller.itemLinks.next')

    unregister: (->
      unless @get 'controller.itemLinks.next'
        @constructor.unregister this
    ).observes('controller.itemLinks.next')

  ModuleView.reopenClass

    views: []

    unregister: (view) ->
      @views.removeObject(view)
      if @views.length is 0
        $window.off 'scroll.moduleView'

    register: (view) ->
      @views.addObject view
      if @views.length is 1
        $window.on 'scroll.moduleView', throttle(@checkViews.bind(this), 100)
      @checkViews()

    checkViews: ->
      for view in @views
        continue if view.get('controller.isLoading')
        {bottom} = view.get('element').getBoundingClientRect()
        if bottom <= window.innerHeight + 100
          view.get('controller').send('loadNextItems')
      null

