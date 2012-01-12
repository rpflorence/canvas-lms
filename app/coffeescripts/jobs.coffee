define [
  'i18n!jobs'
  'jquery'
  'vendor/slickgrid'
  'jquery.ajaxJSON'
  'vendor/slickgrid'
  'jquery.instructure_jquery_patches'
], (I18n, $, _ajaxJSON, Slick) ->

  class FlavorGrid
    constructor: (@options, @type_name, @grid_name) ->
      @data = @options.data
      @$element = $(@grid_name)
      @setTimer() if @options.refresh_rate
      @query = ''

    setTimer: () =>
      setTimeout (=> @refresh(@setTimer)), @options.refresh_rate

    refresh: (cb) =>
      @$element.queue () =>
        $.ajaxJSON @options.url, "GET", { flavor: @options.flavor, q: @query }, (data) =>
          @data.length = 0
          @loading = {}
          @data.push item for item in data[@type_name]
          if data.total && data.total > @data.length
            @data.push({}) for i in [@data.length ... data.total]
          @grid.invalidate()
          cb?()
          @updated?()
          @$element.dequeue()

    change_flavor: (flavor) =>
      @options.flavor = flavor
      @grid.setSelectedRows []
      @refresh()

    grid_options: () ->
      { rowHeight: 20 }

    init: () ->
      @columns = @build_columns()
      @loading = {}
      @grid = new Slick.Grid(@grid_name, @data, @columns, @grid_options())
      this

  class Jobs extends FlavorGrid
    constructor: (options, type_name = 'jobs', grid_name = '#jobs-grid') ->
      Jobs.max_attempts = options.max_attempts if options.max_attempts
      super(options, type_name, grid_name)

    search: (query) ->
      @query = query
      @refresh()

    attempts_formatter: (r,c,d) =>
      return '' unless @data[r].id
      max = (@data[r].max_attempts || Jobs.max_attempts)
      if d == 0
        klass = ''
      else if d < max
        klass = 'has-failed-attempts'
      else if d == @options.on_hold_attempt_count
        klass = 'on-hold'
        d = 'hold'
      else
        klass = 'has-failed-max-attempts'
      out_of = if d == 'hold' then '' else "/ #{max}"
      "<span class='#{klass}'>#{d}#{out_of}</span>"

    load: (row) =>
      @$element.queue () =>
        row = row - (row % @options.limit)
        if @loading[row]
          @$element.dequeue()
          return
        @loading[row] = true
        $.ajaxJSON @options.url, "GET", { flavor: @options.flavor, q: @query, offset: row }, (data) =>
          @data[row ... row + data.jobs.length] = data.jobs
          @grid.invalidate()
          @$element.dequeue()

    id_formatter: (r,c,d) =>
      if @data[r].id
        @data[r].id
      else
        @load(r)
        "<span class='unloaded-id'>-</span>"

    build_columns: () ->
      [
        id: 'id'
        name: I18n.t('columns.id', 'id')
        field: 'id'
        width: 75
        formatter: @id_formatter
      ,
        id: 'tag'
        name: I18n.t('columns.tag', 'tag')
        field: 'tag'
        width: 200
      ,
        id: 'attempts'
        name: I18n.t('columns.attempt', 'attempt')
        field: 'attempts'
        width: 60
        formatter: @attempts_formatter
      ,
        id: 'priority'
        name: I18n.t('columns.priority', 'priority')
        field: 'priority'
        width: 70
      ,
        id: 'strand'
        name: I18n.t('columns.strand', 'strand')
        field: 'strand'
        width: 100
      ,
        id: 'run_at'
        name: I18n.t('columns.run_at', 'run at')
        field: 'run_at'
        width: 165
      ]

    init: () ->
      super()
      @grid.setSelectionModel(new Slick.RowSelectionModel())
      @grid.onSelectedRowsChanged.subscribe =>
        rows = @grid.getSelectedRows()
        row = if rows?.length == 1 then rows[0] else -1
        job = @data[rows[0]] || {}
        $('#show-job .show-field').each (idx, field) =>
          field_name = field.id.replace("job-", '')
          $(field).text(job[field_name] || '')
        $('#job-id-link').attr('href', "/jobs?id=#{job.id}&flavor=#{@options.flavor}")
      if @data.length == 1 && @type_name == 'jobs'
        @grid.setSelectedRows [0]
        @grid.onSelectedRowsChanged.notify()
      this

    selectAll: () ->
      @grid.setSelectedRows([0...@data.length])
      @grid.onSelectedRowsChanged.notify()

    onSelected: (action) ->
      params =
        flavor: @options.flavor
        q: @query
        update_action: action

      if @grid.getSelectedRows().length < 1
        alert('No jobs are selected')
        return

      all_jobs = @grid.getSelectedRows().length == @data.length

      if all_jobs && action == 'destroy'
        return unless confirm(I18n.t('confirm.delete_all', "Are you sure you want to delete *all* jobs of this type and matching this query?"))

      # special case -- if they've selected all, then don't send the ids so that
      # we can operate on jobs that match the query but haven't even been loaded
      # yet
      unless all_jobs
        params.job_ids = (@data[row].id for row in @grid.getSelectedRows())

      $.ajaxJSON @options.batch_update_url, "POST", params, @refresh
      @grid.setSelectedRows []

    updated: () ->
      $('#jobs-total').text @data.length

  class Workers extends Jobs
    constructor: (options) ->
      super(options, 'running', '#running-grid')

    build_columns: () ->
      cols = [
        id: 'worker'
        name: I18n.t('columns.worker', 'worker')
        field: 'locked_by'
        width: 175
      ].concat(super())
      cols.pop()
      cols

    updated: () ->

  class Tags extends FlavorGrid
    constructor: (options) ->
      super(options, 'tags', '#tags-grid')

    build_columns: () ->
      [
        id: 'tag'
        name: I18n.t('columns.tag', 'tag')
        field: 'tag'
        width: 200
      ,
        id: 'count'
        name: I18n.t('columns.count', 'count')
        field: 'count'
        width: 50
      ]

    grid_options: () ->
      $.extend(super(), { enableCellNavigation: false })

  $.extend(window,
    Jobs: Jobs
    Workers: Workers
    Tags: Tags
  )

  $(document).ready () ->
    $('#tags-flavor').change () ->
      window.tags.change_flavor($(this).val())
    $('#jobs-flavor').change () ->
      window.jobs.change_flavor($(this).val())

    $('#jobs-refresh').click () ->
      window.jobs.refresh()

    search_event = if $('#jobs-search')[0].onsearch == undefined then 'change' else 'search'
    $('#jobs-search').bind search_event, () ->
      window.jobs.search $(this).val()

    $('#select-all-jobs').click () -> window.jobs.selectAll()

    $('#hold-jobs').click () -> window.jobs.onSelected('hold')
    $('#un-hold-jobs').click () -> window.jobs.onSelected('unhold')
    $('#delete-jobs').click () -> window.jobs.onSelected('destroy')

    $('#job-handler-show').click () ->
      $('#job-handler-wrapper').clone().dialog
        title: I18n.t('titles.job_handler', 'Job Handler')
        width: 900
        height: 700
        modal: true
      false

    $('#job-last_error-show').click () ->
      $('#job-last_error-wrapper').clone().dialog
        title: I18n.t('titles.last_error', 'Last Error')
        width: 900
        height: 700
        modal: true
      false
