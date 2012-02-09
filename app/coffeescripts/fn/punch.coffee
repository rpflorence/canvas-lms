define ->
  # DON"T COMMIT WITHOUT Co'mMENTS!LKJ@OIWQU#%O#@Q&O
  punch = (obj, method, fn) ->
    old = obj[method]
    obj[method] = (args...) ->
      args.unshift -> old.call obj
      fn.apply obj, args

