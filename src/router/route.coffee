class Route
  constructor: (@parent, path, opt={}) ->
    @_routes = []
    @setFromOptions opt

    # Route options
    @resourceName = opt.resource
    @isResourceMember = opt.resourceMember

    if path
      @buildPath(path)
      @prepareRegExp(parent, @path)


    @namespace = opt.namespace

  prepareRegExp: (parent, path) ->
    @keys = []
    @regexp = pathtoRegexp(@path, @keys, end: false)

  setFromOptions: (opt) ->
    @controller = opt.controller
    @partial = opt.partial

  route: (path, opt={}, childrensCallback) ->
    # copy namespace
    opt.namespace ||= @namespace

    r = new Route @, path, opt
    @_routes.push r
    childrensCallback(r) if childrensCallback
    return r

  resources: (name, opt={}, childrensCallback) ->
    partialPrefix = if @namespace then "#{@namespace}/" else ""
    partialPrefix += "#{name}".replace("//", "/")
    ctrlPrefix = partialPrefix.replace("/", "_")

    index = new Route @, "/#{name}", controller: "#{ctrlPrefix}#index", partial: "/#{partialPrefix}/index", namespace: @namespace
    index.route "/new", controller: "#{ctrlPrefix}#new", partial: "/#{partialPrefix}/new"

    show = index.route "/:id", controller: "#{ctrlPrefix}#show", partial: "/#{partialPrefix}/show", namespace: @namespace, resource: name
    show.route "/edit", controller: "#{ctrlPrefix}#edit", partial: "/#{partialPrefix}/edit", resourceMember: true

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
    {path: @path, controller: @controller, partial: @partial, routes: routes }

  buildPath: (path) ->
    base = ''
    if @parent
      if @parent.resourcePath && !@isResourceMember
        base += @parent.resourcePath
      else
        base += @parent.path

    str = "#{base}/#{path}"

    @path =  str.replace /\/+/g, "/"
    if @resourceName
      resource_name = @resourceName.singularize()
      @resourcePath = "#{base}/:#{resource_name}_id".replace /\/+/g, "/"
