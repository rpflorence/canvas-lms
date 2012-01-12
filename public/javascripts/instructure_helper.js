/**
 * Copyright (C) 2011 Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

//create a global object "INST" that we will have be Instructure's namespace.
define([
  'INST' /* INST */,
  'i18n!instructure',
  'jquery' /* $ */,
  'jquery.instructure_jquery_patches' /* /\.dialog/ */
], function(INST, I18n, $) {

  // add ability to handle css3 opacity transitions on show or hide
  // if you want to use this just add the class 'use-css-transitions-for-show-hide' to an element.
  // whenever that element is .show()n or .hide()n it will use a css opacity transition (in non-IE browsers).
  // if you want to override the length or details of the transition, just specify it in a css file.
  // purposely only supporting ff, webkit & opera because they are the only ones that fire the transitionEnd event, add others when supported
  if (document.body.style.WebkitTransitionProperty !== undefined || document.body.style.MozTransitionProperty !== undefined || document.body.style.OTransitionProperty !== undefined) {

    // if you can't add the class .use-css-transitions-for-show-hide to your element, you need to add it to this
    var selectorForThingsToUseCssTransitions = '.use-css-transitions-for-show-hide',
        secondsToUseForCssTransition = 0.5,
        eventsToBindTo = 'transitionend oTransitionEnd webkitTransitionEnd';
    $('<style>' +
      selectorForThingsToUseCssTransitions + ' {' +
      '    -webkit-transition: opacity '+ secondsToUseForCssTransition +'s;' +
      '    -moz-transition: opacity '+ secondsToUseForCssTransition +'s;' +
      '    -o-transition: opacity '+ secondsToUseForCssTransition +';' +
      '    transition: opacity '+ secondsToUseForCssTransition +'s;' +
      '  }' +
      '</style>').prependTo('head');
    $.each(['show', 'hide', 'remove'], function(i, showHideOrRemove) {
      var previousFn = $.fn[showHideOrRemove];
      $.fn[showHideOrRemove] = function(){
        if (!arguments.length) {
          return this.each(function() {
            var $this = $(this);

            // this.parentNode is to check to make sure it is on the page. because we don't want this:
            // node is not on page, call .remove() on it (sets timeout), put it in page, then afterTransition fires (.remove()ing it from the page again).
            if (this.parentNode && $this.is(selectorForThingsToUseCssTransitions)) {
              $this.queue(function(){
                var oldOpacityCssAttribute = this.style.opacity,
                    oldComputedOpacity = $this.css('opacity'),
                    newOpacity = (showHideOrRemove === 'hide' || showHideOrRemove === 'remove') ? 0 : (!oldComputedOpacity || oldComputedOpacity == "0" ? 1 : oldComputedOpacity);

                if (showHideOrRemove === 'show' && $this.is(':hidden')) {
                  this.style.opacity = 0;
                  previousFn.apply($this); //change out of display:none
                }
                var afterTransition = function(event){
                  // !event means we got here from the setTimout
                  if (!event || event.originalEvent.propertyName === 'opacity') {
                    previousFn.apply($this); //change to display:none when we are hiding.
                    $this[0].style.opacity = oldOpacityCssAttribute;
                    clearTimeout(timeoutToRunIfTransitionEndNeverFires);
                    $this.unbind(eventsToBindTo, afterTransition);
                    $this.dequeue();
                  }
                }
                var timeoutToRunIfTransitionEndNeverFires = setTimeout(afterTransition, secondsToUseForCssTransition*1000+100) //100ms after it should have fired
                $this.bind(eventsToBindTo, afterTransition);
                $this.css('opacity', newOpacity);
              });
            } else {
              previousFn.apply($this);
            }
          });
        } else {
          return previousFn.apply(this, arguments);
        }
      };
    });
  }

  function getTld(hostname){
    hostname = (hostname || "").split(":")[0];
    var parts = hostname.split("."),
        length = parts.length;
    return ( length > 1  ? 
      [ parts[length - 2] , parts[length - 1] ] : 
      parts 
    ).join("");
  }
  var locationTld = getTld(window.location.hostname);
  $.expr[':'].external = function(element){
    var href = $(element).attr('href');
    //if a browser doesnt support <a>.hostname then just dont mark anything as external, better to not get false positives.
    return !!(href && href.length && !href.match(/^(mailto\:|javascript\:)/) && element.hostname && getTld(element.hostname) != locationTld);
  };
    
  window.equella = {
    ready: function(data) {
      $(document).triggerHandler('equella_ready', data);
    },
    cancel: function() {
      $(document).triggerHandler('equella_cancel');
    }
  };
  $(document).bind('equella_ready', function(event, data) {
    $("#equella_dialog").triggerHandler('equella_ready', data);
  }).bind('equella_cancel', function() {
    $("#equella_dialog").dialog('close');
  });
  
  window.external_tool = {
    ready: function(data) {
      $("#external_tool_button_dialog:visible").triggerHandler('selection', data);
      $("#resource_selection_dialog:visible").triggerHandler('selection', data);
    },
    cancel: function() {
      $("#external_tool_button_dialog").dialog('close');
      $("#resource_selection_dialog").dialog('close');
    }
  }
  
  window.jsonFlickrApi = function(data) {
    $("#instructure_image_search").triggerHandler('search_results', data);
  };

});

