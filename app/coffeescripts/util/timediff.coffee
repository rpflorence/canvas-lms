define 'compiled/util/timediff', ['i18n'], (I18n) ->

  I18n = I18n.scoped 'timediff'

  # the strings used to translate the milliseconds into words
  # can be a string or a function (for interpolation, etc.)
  strings =
    prefixAgo: I18n.t('prefix_ago', '')
    prefixFromNow: I18n.t('prefix_from_now', '')
    suffixAgo: I18n.t('suffix_ago', 'ago')
    suffixFromNow: I18n.t('suffix_from_now', 'from now')
    now: I18n.t('now', 'just now')
    seconds: (num) -> I18n.t('seconds', '%{num} seconds', {num: num})
    minute: I18n.t('about_a_minute', 'about a minute')
    minutes: (num) -> I18n.t('minutes', '%{num} minutes', {num: num})
    hour: I18n.t('hour', 'about an hour')
    hours: (num)-> I18n.t('hours', 'about %{num} hours', {num: num})
    day: I18n.t('day', 'a day')
    days: (num) -> I18n.t('days', '%{num} days', {num: num})
    month: I18n.t('month', 'about a month')
    months: (num) -> I18n.t('months', '%{num} months', {num: num})
    year: I18n.t('year', 'about a year')
    years: (num) -> I18n.t('years', '%{num} years', {num: num})
    numbers: []

  trim = (str) ->
    str.replace(/^\s+|\s+$/g, '')

  getWords = (diff) ->
    seconds = diff / 1000
    minutes = seconds / 60
    hours = minutes / 60
    days = hours / 24
    years = days / 365

    substitute = (stringOrFunction, number) ->
      string = if typeof stringOrFunction is 'function' then stringOrFunction(number, diff) else stringOrFunction
      value = (strings.numbers && strings.numbers[number]) || number
      string.replace(/%d/i, value)

    if seconds < 5   then return substitute(strings.now)
    if seconds < 45  then return substitute(strings.seconds, Math.round(seconds))
    if seconds < 90  then return substitute(strings.minute, 1)
    if minutes < 45  then return substitute(strings.minutes, Math.round(minutes))
    if minutes < 90  then return substitute(strings.hour, 1)
    if hours   < 24  then return substitute(strings.hours, Math.round(hours))
    if hours   < 48  then return substitute(strings.day, 1)
    if days    < 30  then return substitute(strings.days, Math.floor(days))
    if days    < 60  then return substitute(strings.month, 1)
    if days    < 365 then return substitute(strings.months, Math.floor(days / 30))
    if years   < 2   then return substitute(strings.year, 1)
    substitute(strings.years, Math.floor(years))

  # exports a function as the module
  # takes nothing more than a number in milliseconds
  # that represents the distance between two time stamps
  return (diff) ->
    prefix = if diff > 0 then strings.prefixAgo else strings.prefixFromNow
    suffix = if diff > 0 then strings.suffixAgo else strings.suffixFromNow
    absDiff = Math.abs diff
    words = getWords absDiff

    return words if absDiff < 5000 # just now, no prefix / suffix
    trim([prefix, words, suffix].join(' '))

