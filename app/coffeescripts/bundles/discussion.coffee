require [
  'compiled/discussions/Discussion'
  'compiled/discussions/DiscussionView'
], (Discussion, DiscussionView) ->

  $ ->
    # global DISCUSSION for shared state across modules
    window.DISCUSSION = new DiscussionView model: new Discussion

