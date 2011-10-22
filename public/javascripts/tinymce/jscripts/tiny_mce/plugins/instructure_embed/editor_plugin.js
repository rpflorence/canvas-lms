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
(function () {
  var $box, $editor, $userURL, $altText, $actions, $flickrLink,
      copy = {};

  I18n.scoped('#tinymce', function (I18n) {
    $.extend(copy, {
      click_to_embed: I18n.t('click_to_embed', 'Click to embed the image'),
      instructions: I18n.t('instructions', "Paste or type the URL of the image you'd like to embed:"),
      url: I18n.t('url', 'URL:'),
      alt_text: I18n.t('alt_text', 'Alternate Text:'),
      search_flickr: I18n.t('alt_text', 'Search flickr creative commons'),
      loading: I18n.t('loading', 'Loading...'),
      embed_external: I18n.t('embed_external', 'Embed External Image'),
      embed_image: I18n.t('embed_image', 'Embed Image'),
      image_not_found: I18n.t('image_not_found', 'Image not found, please try a new URL')
    });
  });

  function initShared () {
    $box = $('<div/>', {html: copy.instructions + "<form id='instructure_embed_prompt_form' style='margin-top: 5px;'><table class='formtable'><tr><td>"+ copy.url +"</td><td><input type='text' class='prompt' style='width: 250px;' value='http://'/></td></tr><tr><td class='nobr'>"+copy.alt_text+"</td><td><input type='text' class='alt_text' style='width: 150px;' value=''/></td></tr><tr><td colspan='2' style='text-align: right;'><input type='submit' value='Embed Image'/></td></tr></table></form><div class='actions'></div>"});
    $altText = $box.find('.alt_text');
    $actions = $box.find('.actions');
    $userURL = $box.find('.prompt');
    $flickrLink = $('<a/>', {
      'class': 'flickr_search_link',
      html: copy.search_flickr,
      href: '#'
    });

    $userURL.bind('keyup', validateURL);
    $actions.delegate('.embed_image_link', 'click', embedURLImage);
    $flickrLink.click(flickrLinkClickHandler);
    $box.append($flickrLink).find('#instructure_embed_prompt_form').submit(embedURLImage);
    $('body').append($box);
  }

  function flickrLinkClickHandler (event) {
    event.preventDefault();
    $box.dialog('close');
    $.findImageForService('flickr_creative_commons', function (data) {
      var $div = $('<div/>'),
          $a = $('<a/>', { href: data.link_url }).appendTo($div),
          $img = $('<img/>', {
            src: data.image_url,
            title: data.title,
            alt: data.title
          }).css({
            'max-width': 500,
            'max-height': 500
          }).appendTo($a);

      $box.dialog('close');
      $editor.editorBox('insert_code', $div.html());
    });
  }

  function embedURLImage (event) {
    var alt = $altText.val() || '',
        text = $userURL.val();

    event.preventDefault();
    event.stopPropagation();
    $editor.editorBox('insert_code', "<img src='" + text + "' alt='" + alt + "'/>");
    $box.dialog('close');
  }

  function validateURL (event) {
    var val = $userURL.val();
    return (val.match(/\.(gif|png|jpg|jpeg)$/)) ? getImage(val) : invalidURL();
  }

  function invalidURL () {
    $actions.empty();
  }

  function getImage (val) {
    var $div = $('<div/>'),
        $img = $('<img/>');

    $div.css('textAlign', 'center').text(copy.loading);
    $actions.empty();
    $actions.append($div);
    $img.attr({
      src: val,
      title: copy.click_to_embed
    })
    .addClass('embed_image_link')
    .css('cursor', 'pointer')
    .bind({
      load: function () {
        var img = $img[0];
        $img.height(img.height < 200 ? img.height : 100);
        $div.empty().append($img);
      },
      error: function () {
        $div.html(copy.image_not_found);
      }
    });
  }

  tinymce.create('tinymce.plugins.InstructureEmbed', {
    init: function (editor, url) {
      var thisEditor = $('#' + editor.id);

      editor.addCommand('instructureEmbed', function (search) {
        $editor = thisEditor; // set shared $editor so images are pasted into the correct editor
        $box.dialog('close').dialog({
          autoOpen: false,
          width: 425,
          height: 'auto',
          title: copy.embed_external,
          open: function () {
            $userURL.select();
          }
        }).dialog('open');

        if (search === 'flickr') $flickrLink.click();
      });

      editor.addButton('instructure_embed', {
        title: copy.embed_image,
        cmd: 'instructureEmbed',
        image: url + '/img/button.gif'
      });
    },

    getInfo: function () {
      return {
        longname: 'InstructureEmbed',
        author: 'Brian Whitmer',
        authorurl: 'http://www.instructure.com',
        infourl: 'http://www.instructure.com',
        version: tinymce.majorVersion + '.' + tinymce.minorVersion
      };
    }
  });

  tinymce.PluginManager.add('instructure_embed', tinymce.plugins.InstructureEmbed);
  $(initShared);
}());
