define ['use!backbone'], (Backbone) ->

  class Participant extends Backbone.Model

    defaults:
      avatar_image_url: ''
      display_name: 'Anonymous'
      id: null

