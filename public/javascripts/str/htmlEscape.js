define(['jquery'], function($) {
  var dummy = $('<div/>');

  var htmlEscape = function(str) {
    return str && str.htmlSafe ?
      str.toString() :
      dummy.text(str).html();
  }

  // Escapes HTML tags from string, or object string props of `strOrObject`.
  // returns the new string, or the object with escaped properties
  return function(strOrObject) {
    if (typeof strOrObject === 'string') {
      return htmlEscape(strOrObject);
    }

    var k, v;
    for (k in strOrObject) {
      v = strOrObject[k];
      if (typeof v === "string") {
        strOrObject[k] = htmlEscape(v);
      }
    }
    return strOrObject;
  }
});

