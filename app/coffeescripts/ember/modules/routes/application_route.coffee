define ['ember'], (Ember) ->

  ApplicationRoute = Ember.Route.extend

    model: (params) ->
      @get('store').findAll('module')

