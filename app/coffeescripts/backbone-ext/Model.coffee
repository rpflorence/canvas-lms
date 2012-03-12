define ['use!backbone', 'use!underscore'], (Backbone, _) ->

  _.extend Backbone.Model.prototype,

    initialize: ->
      @_configureAttributeMethods() if @attributeMethods?

    _configureAttributeMethods: ->
      set = (methodName) => @set methodName, @[methodName]()
      _.each @attributeMethods, (dependencies, methodName) =>
        set methodName
        if dependencies?
          eventName = _.map(dependencies, (name) -> "change:#{name}").join ' '
          @bind eventName, -> set methodName

  Backbone.Model

