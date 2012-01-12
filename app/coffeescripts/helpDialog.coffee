# also requires
# jquery.formSubmit
# $.detect from jquery_misc_helpers
# jqueryui dialog
# jquery disableWhileLoading

define 'compiled/helpDialog', [
  'i18n!HelpDialog'
  'jst/helpDialog'
  'INST'

  'jquery.instructure_misc_helpers'
  'jquery.instructure_jquery_patches' # dialog
  'jquery.disableWhileLoading'
], (I18n, helpDialogTemplate, INST) ->

  helpDialog =
    defaultLinks: [
      {
        available_to: ['student']
        text: I18n.t 'instructor_question', 'Ask your instructor a question'
        subtext: I18n.t 'instructor_question_sub', 'Questions are submitted to your instructor'
        url: '#teacher_feedback'
      },
      {
        available_to: ['student', 'teacher', 'admin']
        text: I18n.t 'search_the_canvas_guides', 'Search the Canvas Guides'
        subtext: I18n.t 'canvas_help_sub', 'Find answers to common questions'
        url: 'http://guides.instructure.com'
      },
      {
        available_to: ['user', 'student', 'teacher', 'admin']
        text: I18n.t 'report_problem', 'Report a problem'
        subtext: I18n.t 'report_problem_sub', 'If Canvas misbehaves, tell us about it'
        url: '#create_ticket'
      }
    ]

    defaultTitle: I18n.t 'Help', "Help"

    initDialog: ->
      @$dialog = $('<div style="padding:0; overflow: visible;" />').dialog
        resizable: false
        width: 400
        title: @defaultTitle
        close: => @switchTo('#help-dialog-options')

      @$dialog.dialog('widget').delegate 'a[href="#teacher_feedback"],
                                          a[href="#create_ticket"],
                                          a[href="#help-dialog-options"]', 'click', (event) =>
        event.preventDefault()
        @switchTo $(event.currentTarget).attr('href')

      @helpLinksDfd = $.getJSON('/help_links').done (links) =>
        # only show the links that are available to the roles of this user
        links = $.grep @defaultLinks.concat(links), (link) ->
          $.detect link.available_to, (role) ->
            role in ENV.current_user_roles
        locals =
          showEmail: not ENV.current_user_id
          helpLinks: links
          showBadBrowserMessage: INST.browser.ie
          browserVersion: INST.browser.version

        @$dialog.html(helpDialogTemplate locals)
        @initTicketForm()
        $(@).trigger('ready')
      @$dialog.disableWhileLoading @helpLinksDfd
      @dialogInited = true

    initTicketForm: ->
      $form = @$dialog.find('#create_ticket').formSubmit
        disableWhileLoading: true
        required: ['error[subject]', 'error[comments]', 'error[user_perceived_severity]']
        success: =>
          @$dialog.dialog('close')
          $form.find(':input').val('')

    switchTo: (panelId) ->
      toggleablePanels = "#teacher_feedback, #create_ticket"
      @$dialog.find(toggleablePanels).hide()

      newHeight = @$dialog.find(panelId).show().outerHeight()
      @$dialog.animate({
        left : if toggleablePanels.match(panelId) then -400 else 0
        height: newHeight
      }, {
        step: =>
          #reposition vertically to reflect current height
          @$dialog.dialog('option', 'position', 'center')
        duration: 100
      })

      if newTitle = @$dialog.find("a[href='#{panelId}'] .text").text()
        newTitle = $("
          <a class='ui-dialog-header-backlink' href='#help-dialog-options'>
            #{I18n.t('Back', 'Back')}
          </a>
          <span>#{newTitle}</span>
        ")
      else
        newTitle = @defaultTitle
      @$dialog.dialog 'option', 'title', newTitle

    open: ->
      @initDialog() unless @dialogInited
      @$dialog.dialog('open')
      @initTeacherFeedback()

    initTeacherFeedback: ->
      if !@teacherFeedbackInited and 'student' in ENV.current_user_roles
        @teacherFeedbackInited = true
        coursesDfd = $.getJSON '/api/v1/courses.json'
        $form = null
        @helpLinksDfd.done =>
          $form = @$dialog.find("#teacher_feedback")
            .disableWhileLoading(coursesDfd)
            .formSubmit
              disableWhileLoading: true
              required: ['recipients[]', 'body'],
              success: =>
                @$dialog.dialog('close')

        $.when(coursesDfd, @helpLinksDfd).done (coursesDfdArgs) ->
          options = ("<option value='course_#{c.id}_admins' #{if ENV.context_id is c.id then 'selected' else ''}>
                      #{$.htmlEscape(c.name)}
                    </option>" for c in coursesDfdArgs[0])
          $form.find('[name="recipients[]"]').html(options.join '')

    initTriggers: ->
      $('.help_dialog_trigger').click (event) =>
        event.preventDefault()
        @open()

