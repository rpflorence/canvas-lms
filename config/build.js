({

  // file optimizations
  optimize: "uglify",

  // continue to let Jammit do its thing
  optimizeCss: "none",

  // where to place optimized javascript, relative to this file
  dir: "../public/optimized",

  // where the "app" is, relative to this file
  appDir: "../public/javascripts",

  // base path for modules, relative to appDir
  baseUrl: "./",

  translate: true,

  // paths we have set up (matches require onfig in application.html.erb)
  paths: {
    common: 'compiled/bundles/common',
    jquery: 'vendor/jquery-1.6.4',
    jqueryui: 'vendor/jqueryui',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone',
    uploadify: '../flash/uploadify/jquery.uploadify.v2.1.4',
    use: 'vendor/use'
  },

  // non-amd shims
  use: {
    backbone: {
      deps: ['use!underscore', 'jquery'],
      attach: 'Backbone'
    },
    underscore: {
      attach: '_'
    }
  },

  // which modules should have their dependencies concatenated into them
  modules: [

    // non "app" bundles, should be careful not to try to have too many of these
    {
      name: "compiled/tinymce",

      // this stuff is already in common, should be able to make this a smaller
      // list since some things depend on others in the list, yes, its a bit crazy
      // this is the intersection of common and tinymce, we need to script this
      // config file...
      exclude: [
        'order',
        'i18n',
        'str/escapeRegex',
        'vendor/date',
        'vendor/jquery-1.6.4',
        'str/pluralize',
        'INST',
        'str/htmlEscape',
        'i18nObj',
        'vendor/jquery.scrollTo',
        'vendor/jqueryui/core',
        'vendor/jqueryui/widget',
        'vendor/jqueryui/mouse',
        'vendor/jqueryui/position',
        'translations/instructure',
        'i18n!instructure',
        'compiled/util/objectCollection',
        'vendor/spin',
        'vendor/jquery.spin',
        'jquery.google-analytics',
        'vendor/jquery.ba-hashchange',
        'vendor/jqueryui/effects/core',
        'vendor/jqueryui/effects/drop',
        'jquery.rails_flash_notifications',
        'translations/scribd',
        'i18n!scribd',
        'vendor/scribd.view',
        'vendor/jquery.ba-throttle-debounce',
        'vendor/jquery.store',
        'jquery.dropdownList',
        'vendor/jqueryui/progressbar',
        'translations/media_comments',
        'i18n!media_comments',
        'vendor/jqueryui/button',
        'vendor/jqueryui/draggable',
        'instructure-jquery.ui.draggable-patch',
        'vendor/jqueryui/resizable',
        'vendor/jqueryui/dialog',
        'jquery.instructure_jquery_patches',
        'vendor/jqueryui/datepicker',
        'vendor/jqueryui/sortable',
        'jquery.scrollToVisible',
        'vendor/jqueryui/tabs',
        'jquery.disableWhileLoading',
        'jquery.keycodes',
        'jquery.instructure_date_and_time',
        'jquery.instructure_misc_plugins',
        'tinymce.editor_box',
        'jquery.instructure_forms',
        'jquery.ajaxJSON',
        'jquery.instructure_misc_helpers',
        'media_comments'
      ]
    },

    { name: "common" },

    // "apps"
    { name: "compiled/bundles/account_settings", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/account_statistics", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/alerts", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/aligned_outcomes", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/assignmentMuter", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/assignments", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/attendance", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/calendar", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/calendar_event", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/collaborations", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/conferences", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/content_exports", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/content_migration", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/context_modules", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/course", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/course_settings", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/dashboard", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/datagrid", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/discussion_replies", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/edit_rubric", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/eportfolio", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/file_inline", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/full_assignment", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/full_files", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/grade_summary", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/gradebook2", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/gradebook_history", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/gradebook_uploads", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/gradebooks", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/grading_standards", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/groups", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/jobs", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/jquery_ui_menu", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/json2", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/learning_outcome", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/learning_outcomes", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/link_enrollment", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/manage_avatars", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/manage_groups", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/messages", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/moderate_quiz", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/plugins", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/prerequisites_lookup", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/profile", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/question_bank", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/question_banks", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/quiz_show", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/quizzes_bundle", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/quizzes_index", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/rubric_assessment", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/section", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/select_content_dialog", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/sis_import", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/site_admin", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/slickgrid", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/speed_grader", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/sub_accounts", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/syllabus", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/take_quiz", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/teacher_activity_report", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/tool_inline", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/topic", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/topics", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/user", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/user_lists", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/user_logins", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/user_name", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/user_notes", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/user_sortable_name", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/wiki", exclude: ['common', 'compiled/tinymce'] },
    { name: "compiled/bundles/calendar2", exclude: ['common', 'compiled/tinymce'] }
  ]
})

