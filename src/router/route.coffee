class Route
  constructor: (parent, path, opt={}) ->
    @_routes = []
    @setFromOptions opt
    @prepareRegExp(parent, path) if path

  prepareRegExp: (parent, path) ->
    @path = @_fullPath(parent, path)
    @keys = []
    @regexp = pathtoRegexp(@path, @keys, end: false)

  setFromOptions: (opt) ->
    @controller = opt.controller
    @layout = opt.layout

  route: (path, opt={}, childrensCallback) ->
    r = new Route @, path, opt
    @_routes.push r
    childrensCallback(r) if childrensCallback
    return r

  find: (path) ->
    res = @regexp.exec path

    return false unless res

    # If this match initally, then ask to his childrens in order to
    # obtain the complete match
    for child in @_routes
      return r if r = child.find(path)

    # Extract params
    params = {}
    if @keys.length
      for k, index in @keys
        params[k.name] = res[index + 1]

    return { route: @, params: params }


  _fullPath: (parent, path) ->
    str = if parent then parent.path else ''
    str += "/#{path}"
    return str.replace /\/+/g, "/"
