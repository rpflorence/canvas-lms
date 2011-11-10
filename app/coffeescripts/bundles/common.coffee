require [
  # true modules that we manage in this file
  'compiled/widget/courseList'
  'compiled/helpDialog'

  # modules that do their own thing on every page that simply need to
  # be required
  'translations/_core_en'
  'vendor/firebugx'
  'jquery.google-analytics'
  'vendor/swfobject/swfobject'
  'reminders'
  'jquery.instructure_forms'
  'tinymce.editor_box'
  'instructure'
  'ajax_errors'
  'page_views'
  'feedback'
  'compiled/license_help'

  # random modules required by the js_blocks, put them all in here
  # so RequireJS doesn't try to load them before common is loaded
  # in an optimized environment
  'gradebook_uploads'
  'jquery.fancyplaceholder'
  'jqueryui/autocomplete'
  'link_enrollment'
  'media_comments'
  'rubric_assessment'
  'tinymce.editor_box'
  'vendor/graphael'
  'vendor/jquery.pageless'
  'vendor/jquery.scrollTo'
], (courseList, helpDialog) ->
  courseList.init()
  helpDialog.initTriggers()

