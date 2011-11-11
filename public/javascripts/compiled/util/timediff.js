(function() {
  define('compiled/util/timediff', ['i18n'], function(I18n) {
    var getWords, strings, trim;
    I18n = I18n.scoped('timediff');
    strings = {
      prefixAgo: I18n.t('prefix_ago', ''),
      prefixFromNow: I18n.t('prefix_from_now', ''),
      suffixAgo: I18n.t('suffix_ago', 'ago'),
      suffixFromNow: I18n.t('suffix_from_now', 'from now'),
      now: I18n.t('now', 'just now'),
      seconds: function(num) {
        return I18n.t('seconds', '%{num} seconds', {
          num: num
        });
      },
      minute: I18n.t('about_a_minute', 'about a minute'),
      minutes: function(num) {
        return I18n.t('minutes', '%{num} minutes', {
          num: num
        });
      },
      hour: I18n.t('hour', 'about an hour'),
      hours: function(num) {
        return I18n.t('hours', 'about %{num} hours', {
          num: num
        });
      },
      day: I18n.t('day', 'a day'),
      days: function(num) {
        return I18n.t('days', '%{num} days', {
          num: num
        });
      },
      month: I18n.t('month', 'about a month'),
      months: function(num) {
        return I18n.t('months', '%{num} months', {
          num: num
        });
      },
      year: I18n.t('year', 'about a year'),
      years: function(num) {
        return I18n.t('years', '%{num} years', {
          num: num
        });
      },
      numbers: []
    };
    trim = function(str) {
      return str.replace(/^\s+|\s+$/g, '');
    };
    getWords = function(diff) {
      var days, hours, minutes, seconds, substitute, years;
      seconds = diff / 1000;
      minutes = seconds / 60;
      hours = minutes / 60;
      days = hours / 24;
      years = days / 365;
      substitute = function(stringOrFunction, number) {
        var string, value;
        string = typeof stringOrFunction === 'function' ? stringOrFunction(number, diff) : stringOrFunction;
        value = (strings.numbers && strings.numbers[number]) || number;
        return string.replace(/%d/i, value);
      };
      if (seconds < 5) {
        return substitute(strings.now);
      }
      if (seconds < 45) {
        return substitute(strings.seconds, Math.round(seconds));
      }
      if (seconds < 90) {
        return substitute(strings.minute, 1);
      }
      if (minutes < 45) {
        return substitute(strings.minutes, Math.round(minutes));
      }
      if (minutes < 90) {
        return substitute(strings.hour, 1);
      }
      if (hours < 24) {
        return substitute(strings.hours, Math.round(hours));
      }
      if (hours < 48) {
        return substitute(strings.day, 1);
      }
      if (days < 30) {
        return substitute(strings.days, Math.floor(days));
      }
      if (days < 60) {
        return substitute(strings.month, 1);
      }
      if (days < 365) {
        return substitute(strings.months, Math.floor(days / 30));
      }
      if (years < 2) {
        return substitute(strings.year, 1);
      }
      return substitute(strings.years, Math.floor(years));
    };
    return function(diff) {
      var absDiff, prefix, suffix, words;
      prefix = diff > 0 ? strings.prefixAgo : strings.prefixFromNow;
      suffix = diff > 0 ? strings.suffixAgo : strings.suffixFromNow;
      absDiff = Math.abs(diff);
      words = getWords(absDiff);
      if (absDiff < 5000) {
        return words;
      }
      return trim([prefix, words, suffix].join(' '));
    };
  });
}).call(this);
