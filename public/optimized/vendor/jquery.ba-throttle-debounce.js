/*!
 * jQuery throttle / debounce - v1.1 - 3/7/2010
 * http://benalman.com/projects/jquery-throttle-debounce-plugin/
 * 
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
define(["jquery"],function(a){var b;a.throttle=b=function(b,c,d,e){function h(){function j(){g=+(new Date),d.apply(a,i)}function k(){f=undefined}var a=this,h=+(new Date)-g,i=arguments;e&&!f&&j(),f&&clearTimeout(f),e===undefined&&h>b?j():c!==!0&&(f=setTimeout(e?k:j,e===undefined?b-h:b))}var f,g=0;return typeof c!="boolean"&&(e=d,d=c,c=undefined),a.guid&&(h.guid=d.guid=d.guid||a.guid++),h},a.debounce=function(a,c,d){return d===undefined?b(a,c,!1):b(a,d,c!==!1)}})