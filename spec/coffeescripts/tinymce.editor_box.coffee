define [
  'jquery'
  'helpers/loadFixture'
  'compiled/tinymce'
], ($, loadFixture, @localTiny) ->

  module 'tinymce.editor_box'
  fixture = loadFixture 'textarea'
  @textarea = fixture.find 'textarea'

