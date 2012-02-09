# trick tiny into not loading CSS and editor plugins for us
window.tinyMCEPreInit =
  suffix: ''
  base: ''
  query: ''

window.tinyMCE_GZ = loaded: true

define [
  'compiled/editor/stocktiny'
  'compiled/editor/markScriptsLoaded'

  # instructure plugins
  'editor/contextmenu/editor_plugin'
  'editor/embed/editor_plugin'
  'editor/equation/editor_plugin'
  'editor/equella/editor_plugin'
  'editor/external_tools/editor_plugin'
  'editor/links/editor_plugin'
  'editor/record/editor_plugin'
], (tinyMCE, markScriptsLoaded) ->

  # prevents tiny from trying to load these dynamically
  markScriptsLoaded [
    'plugins/contextmenu/editor_plugin'
    'plugins/embed/editor_plugin'
    'plugins/equation/editor_plugin'
    'plugins/equella/editor_plugin'
    'plugins/external_tools/editor_plugin'
    'plugins/links/editor_plugin'
    'plugins/record/editor_plugin'
  ]

  tinyMCE

