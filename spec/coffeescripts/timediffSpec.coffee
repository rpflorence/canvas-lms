define ['compiled/util/timediff'], (timediff) ->

  second = 1000
  minute = second * 60
  hour = minute * 60
  day = hour * 24
  year = day * 365

  module 'timediff'

  test 'now', ->
    words = timediff(0)
    equal(words, 'just now')

  test 'seconds', ->
    words = timediff(second * 44)
    equal(words, '44 seconds ago')

  test 'minute', ->
    words = timediff(second * 89)
    equal(words, 'about a minute ago')

  test 'minutes', ->
    words = timediff(minute * 44)
    equal(words, '44 minutes ago')

  test 'hour', ->
    words = timediff(minute * 89)
    equal(words, 'about an hour ago')

  test 'hours', ->
    words = timediff(hour * 23)
    equal(words, 'about 23 hours ago')

  test 'day', ->
    words = timediff(hour * 47)
    equal(words, 'a day ago')

  test 'days', ->
    words = timediff(day * 29)
    equal(words, '29 days ago')

  test 'month', ->
    words = timediff(day * 59)
    equal(words, 'about a month ago')

  test 'months', ->
    words = timediff(day * 364)
    equal(words, '12 months ago')

  test '2 months', ->
    words = timediff(day * 30 * 2)
    equal(words, '2 months ago')

  test 'year', ->
    words = timediff(year * 1.9)
    equal(words, 'about a year ago')

  test 'years', ->
    words = timediff(year * 2)
    equal(words, '2 years ago')

