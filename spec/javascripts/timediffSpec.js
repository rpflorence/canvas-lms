(function() {
  define(['compiled/util/timediff'], function(timediff) {
    var day, hour, minute, second, year;
    second = 1000;
    minute = second * 60;
    hour = minute * 60;
    day = hour * 24;
    year = day * 365;
    module('timediff');
    test('now', function() {
      var words;
      words = timediff(0);
      return equal(words, 'just now');
    });
    test('seconds', function() {
      var words;
      words = timediff(second * 44);
      return equal(words, '44 seconds ago');
    });
    test('minute', function() {
      var words;
      words = timediff(second * 89);
      return equal(words, 'about a minute ago');
    });
    test('minutes', function() {
      var words;
      words = timediff(minute * 44);
      return equal(words, '44 minutes ago');
    });
    test('hour', function() {
      var words;
      words = timediff(minute * 89);
      return equal(words, 'about an hour ago');
    });
    test('hours', function() {
      var words;
      words = timediff(hour * 23);
      return equal(words, 'about 23 hours ago');
    });
    test('day', function() {
      var words;
      words = timediff(hour * 47);
      return equal(words, 'a day ago');
    });
    test('days', function() {
      var words;
      words = timediff(day * 29);
      return equal(words, '29 days ago');
    });
    test('month', function() {
      var words;
      words = timediff(day * 59);
      return equal(words, 'about a month ago');
    });
    test('months', function() {
      var words;
      words = timediff(day * 364);
      return equal(words, '12 months ago');
    });
    test('2 months', function() {
      var words;
      words = timediff(day * 30 * 2);
      return equal(words, '2 months ago');
    });
    test('year', function() {
      var words;
      words = timediff(year * 1.9);
      return equal(words, 'about a year ago');
    });
    return test('years', function() {
      var words;
      words = timediff(year * 2);
      return equal(words, '2 years ago');
    });
  });
}).call(this);
