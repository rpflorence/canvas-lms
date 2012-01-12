define [
  'i18n!calendar'
], (I18n) ->

  class
    constructor: (data, contextInfo) ->
      @eventType = 'generic'
      @contextInfo = contextInfo
      @allPossibleContexts = null
      @className = []
      @object = {}

    isNewEvent: () =>
      @eventType == 'generic' || !@object?.id

    isAppointmentGroupFilledEvent: () =>
      @object?.child_events?.length > 0

    isAppointmentGroupEvent: () =>
      @object?.appointment_group_url

    contextCode: () =>
      @object?.context_code || @contextInfo?.asset_string

    isUndated: () =>
      @start == null

    displayTimeString: () -> ""
    readableType: () -> ""

    fullDetailsURL: () -> null

    startDate: () -> @date
    endDate: () -> @startDate()

    possibleContexts: () -> @allPossibleContexts || [ @contextInfo ]

    addClass: (newClass) =>
      found = false
      for c in @className
        if c == newClass
          found = true
          break
      if !found then @className.push newClass

    removeClass: (rmClass) =>
      idx = 0
      for c in @className
        if c == rmClass
          @className.splice(idx, 1)
        else
          idx += 1

    save: (params, success, error) =>
      onSuccess = (data) =>
        @copyDataFromObject(data)
        $.publish "CommonEvent/eventSaved", this
        success?()

      onError = (data) =>
        $.publish "CommonEvent/eventSaveFailed", this
        error?()

      [ method, url ] = @methodAndURLForSave()

      $.publish "CommonEvent/eventSaving", this
      $.ajaxJSON url, method, params, onSuccess, onError
