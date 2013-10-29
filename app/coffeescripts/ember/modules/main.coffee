# this is auto-generated
define ["ember", "compiled/ember/modules/config/app", "compiled/ember/modules/config/routes", "compiled/ember/modules/controllers/module_controller", "compiled/ember/modules/routes/modules_route", "compiled/ember/modules/views/module_view", "compiled/ember/modules/templates/modules"], (Ember, App, routes, ModuleController, ModulesRoute, ModuleView) ->

  App.initializer
    name: 'routes'
    initialize: (container, application) ->
      application.Router.map(routes)

  App.reopen({
    ModuleController: ModuleController
    ModulesRoute: ModulesRoute
    ModuleView: ModuleView
  })
