/*!
 * jQuery Tiny Pub/Sub - v0.6 - 1/10/2011
 * http://benalman.com/
 *
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
define(["jquery"],function(a){var b=a({});a.subscribe=function(c,d){function e(){return d.apply(this,Array.prototype.slice.call(arguments,1))}e.guid=d.guid=d.guid||a.guid++,b.bind(c,e)},a.unsubscribe=function(){b.unbind.apply(b,arguments)},a.publish=function(){b.trigger.apply(b,arguments)}})