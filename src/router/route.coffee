class Route
  constructor: (parent, path, opt={}) ->
    @_routes = []
    @setFromOptions opt
    @prepareRegExp(parent, path) if path
    @namespace = opt.namespace

  prepareRegExp: (parent, path) ->
    @path = @_fullPath(parent, path)
    @keys = []
    @regexp = pathtoRegexp(@path, @keys, end: false)

  setFromOptions: (opt) ->
    @controller = opt.controller
    @layout = opt.layout

  route: (path, opt={}, childrensCallback) ->
    # copy namespace
    opt.namespace ||= @namespace

    r = new Route @, path, opt
    @_routes.push r
    childrensCallback(r) if childrensCallback
    return r

  resources: (name, opt={}, childrensCallback) ->
    layoutPrefix = if @namespace then "#{@namespace}/" else ""
    layoutPrefix += "#{name}".replace("//", "/")
    ctrlPrefix = layoutPrefix.replace("/", "_")

    index = new Route @, "/#{name}", controller: "#{ctrlPrefix}#index", layout: "/#{layoutPrefix}/index", namespace: @namespace
    index.route "/new", controller: "#{ctrlPrefix}#new", layout: "/#{layoutPrefix}/new"
    show = index.route "/:id", controller: "#{ctrlPrefix}#show", layout: "/#{layoutPrefix}/show", namespace: @namespace
    show.route "/edit", controller: "#{ctrlPrefix}#edit", layout: "/#{layoutPrefix}/edit"

    @_routes.push(index)
    # Add childrens from callbacks.
    # This time we pass 2 arguments: member and collection
    childrensCallback(show, index) if childrensCallback

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


  toHash: ->
    routes = []
    routes.push r.toHash() for r in @_routes
    {path: @path, controller: @controller, layout: @layout, routes: routes }

  _fullPath: (parent, path) ->
    str = if parent then parent.path else ''
    str += "/#{path}"
    return str.replace /\/+/g, "/"
