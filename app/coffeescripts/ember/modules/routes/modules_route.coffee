define ['ember', 'jquery'], (Ember, $) ->

  ModulesRoute = Ember.Route.extend

    model: ->
      $.getJSON "/api/v1/courses/#{ENV.course_id}/modules?include[]=items"

