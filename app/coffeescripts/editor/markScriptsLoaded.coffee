define ['tinymce/jscripts/tiny_mce/tiny_mce_src'], ->

  markScriptLoaded = (urls) ->
    for url in urls
      id = tinymce.baseURI.toAbsolute(url) + '.js'
      tinymce.ScriptLoader.markDone id

