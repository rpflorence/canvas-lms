define ['ember-data'], ({Model, attr, hasMany}) ->

  Module = Model.extend

    name: attr()

    moduleItems: hasMany 'moduleItem'

