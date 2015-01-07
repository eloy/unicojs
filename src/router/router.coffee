class HistoryDriver
  get: ->
    location.pathname

  set: (url, scope, title) ->
    history.pushState(scope, title, url);
    @listener(@get())

  addEventListener: (@listener) ->
    window.onpopstate = (=> @listener(@get()))


class HashDriver
  get: ->
    location.hash.substr(1)

  set: (url, scope, title) ->
    location.hash = "##{url}"

  addEventListener: (@listener) ->
    window.onpopstate = (=> @listener(@get()))

class UnicoRouter
  constructor: (opt={}) ->
    @root = new Route null, '/'
    # Initialize the driver, hash by default
    if opt.type == 'history'
      @driver = new HistoryDriver()
    else
      @driver = new HashDriver()
    @_routeChangedListeners = []
    @currentPath = undefined
    return true

  # Add listener and find current route
  start: ->
    # Add listener
    @driver.addEventListener (path) =>
      @_routeChanged(path)

    # Send Event with current route
    @_routeChanged @driver.get()

  visit: (target) ->
    @driver.set target

  route: (path, opt={}, childrensCallback) ->
    @root.route path, opt, childrensCallback

  resources: (name, opt={}, childrensCallback) ->
    @root.resources(name, opt, childrensCallback)
  rootOptions: (opt) ->
    @root.setFromOptions opt

  find: (path) ->
    @root.find path

  addRouteChangedListener: (listener) ->
    @_routeChangedListeners.push listener

  _routeChanged: (path) ->
    @currentPath = path
    route = @find(path)
    for listener in @_routeChangedListeners
      listener(route, path)
