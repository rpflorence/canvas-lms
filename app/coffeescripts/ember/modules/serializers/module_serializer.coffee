define ['./application_serializer'], (ApplicationSerializer) ->

  ModuleSerializer = ApplicationSerializer.extend

    # converts payload from
    #
    #   {
    #     modules: [{ id: 1, items: [{id: 2}] }]
    #   }
    #
    #   to
    #
    #   {
    #     modules: [{ id: 1, items: [2] }],
    #     moduleItems: [{id: 2}]
    #   }

    normalizePayload: (type, payload) ->
      payload.moduleItems = []
      @normalizeModule(module, payload) for module in payload.modules
      payload

    normalizeModule: (module, payload) ->
      module.moduleItems = []
      module.items ?= []
      @normalizeItem(item, module, payload) for item in module.items
      delete module.items

    normalizeItem: (item, module, payload) ->
      module.moduleItems.push item.id
      payload.moduleItems.push item

