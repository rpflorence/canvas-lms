define ['./application_adapter'], (ApplicationAdapter) ->

  ModuleAdapter = ApplicationAdapter.extend

    buildURL: (type, id) ->
      url = @_super.apply this, arguments
      "#{url}?include[]=items"

