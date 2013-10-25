# this is auto-generated
define ["ember", "compiled/ember/modules/config/app", "compiled/ember/modules/config/routes", "compiled/ember/modules/adapters/application_adapter", "compiled/ember/modules/adapters/module_adapter", "compiled/ember/modules/models/module", "compiled/ember/modules/models/module_item", "compiled/ember/modules/routes/application_route", "compiled/ember/modules/serializers/application_serializer", "compiled/ember/modules/serializers/module_serializer", "compiled/ember/modules/templates/application"], (Ember, App, routes, ApplicationAdapter, ModuleAdapter, Module, ModuleItem, ApplicationRoute, ApplicationSerializer, ModuleSerializer) ->

  App.initializer
    name: 'routes'
    initialize: (container, application) ->
      application.Router.map(routes)

  App.reopen({
    ApplicationAdapter: ApplicationAdapter
    ModuleAdapter: ModuleAdapter
    Module: Module
    ModuleItem: ModuleItem
    ApplicationRoute: ApplicationRoute
    ApplicationSerializer: ApplicationSerializer
    ModuleSerializer: ModuleSerializer
  })
