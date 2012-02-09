(function() {
  define(['jquery', 'helpers/loadFixture', 'compiled/tinymce'], function($, loadFixture, localTiny) {
    var fixture;
    this.localTiny = localTiny;
    module('tinymce.editor_box');
    fixture = loadFixture('textarea');
    return this.textarea = fixture.find('textarea');
  });
}).call(this);
