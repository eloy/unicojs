class HistoryDriver
  get: ->
    location.pathname


  set: (url, scope, title) ->
    history.pushState(scope, title, url);
    @listener(@get())

  addEventListener: (@listener) ->
    window.onpopstate = (=> @listener(@get()))

class UnicoRouter
  constructor: ->
    @root = new Route null, '/'
    @driver = new HistoryDriver()
    @currentPath = undefined

  # Add listener and find current route
  start: ->
    @driver.addEventListener (path) =>
      @routeChanged(path)
    @routeChanged @driver.get()

  visit: (target) ->
    @driver.set target

  routeChanged: (path) ->
    @currentPath = path
    route = @find(path)
    console.log route

  route: (path, opt={}) ->
    @root.route path, opt

  root: (opt) ->
    @root.setFromOptions opt

  find: (path) ->
    @root.find path
