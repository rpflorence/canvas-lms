/*!
 * jQuery hashchange event - v1.3 - 7/21/2010
 * http://benalman.com/projects/jquery-hashchange-plugin/
 * 
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
define(["jquery"],function(a){function h(a){return a=a||location.href,"#"+a.replace(/^[^#]*#?(.*)$/,"$1")}"$:nomunge";var b="hashchange",c=document,d,e=a.event.special,f=c.documentMode,g="on"+b in window&&(f===undefined||f>7);a.fn[b]=function(a){return a?this.bind(b,a):this.trigger(b)},a.fn[b].delay=50,e[b]=a.extend(e[b],{setup:function(){if(g)return!1;a(d.start)},teardown:function(){if(g)return!1;a(d.stop)}}),d=function(){function l(){var c=h(),d=k(f);c!==f?(j(f=c,d),a(window).trigger(b)):d!==f&&(location.href=location.href.replace(/#.*/,"")+d),e=setTimeout(l,a.fn[b].delay)}var d={},e,f=h(),i=function(a){return a},j=i,k=i;return d.start=function(){e||l()},d.stop=function(){e&&clearTimeout(e),e=undefined},a.browser.msie&&!g&&function(){var e,f;d.start=function(){e||(f=a.fn[b].src,f=f&&f+h(),e=a('<iframe tabindex="-1" title="empty"/>').hide().one("load",function(){f||j(h()),l()}).attr("src",f||"javascript:0").insertAfter("body")[0].contentWindow,c.onpropertychange=function(){try{event.propertyName==="title"&&(e.document.title=c.title)}catch(a){}})},d.stop=i,k=function(){return h(e.location.href)},j=function(d,f){var g=e.document,h=a.fn[b].domain;d!==f&&(g.title=c.title,g.open(),h&&g.write('<script>document.domain="'+h+'"</script>'),g.close(),e.location.hash=d)}}(),d}()})