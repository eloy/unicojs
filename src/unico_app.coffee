# Main app
#----------------------------------------------------------------------

class UnicoApp
  @builtInDirectives = {}

  constructor: (@opt={})->
    @controllers = {}
    @directives = UnicoApp.builtInDirectives
    @_mountedCallbacks = []

    if @opt.enableRouter
      @router = @_createRouter()
      @tmplFactory = new TemplateFactory(base: @opt.templateBasePath)

  addController: (name, clazz) ->
    @controllers[name] = clazz

  addDirective: (name, clazz) ->
    @directives[name] = clazz

  refresh: ->
    if @instances
      i.changed() for i in @instances
    else if @reactRender
      console.log "r"
      @reactRender.setProps()

    true

  # One Time Render
  #----------------------------------------------------------------------

  render: ->
    @instances = []
    # Search for controllers
    for el in document.querySelectorAll("[controller]")
      controllerName = el.getAttribute 'controller'
      instance = new UnicoInstance @, controllerName
      instance.build(el)
      @instances.push instance
    return @


  # Router
  #----------------------------------------------------------------------

  visit: (path) ->
    @router.visit path

  startRouter: ->
    @router.start()

  addMountListener: (listener) ->
    @_mountedCallbacks.push listener

  _loadRoute: (request, path) ->
    try
      body = document.querySelector @opt.targetElement
      ctrlName = request.route.controller
      instance = new UnicoInstance @, ctrlName
      @instances = [instance]
      instance.buildRoute request, path, body

    catch error
      console.error(error.stack) if @debug
      return false

  _createRouter: ->
    router = new UnicoRouter()
    router.addRouteChangedListener (request, path) =>
      @_loadRoute(request, path)
    @opt.targetElement ||= "body"
    return router

  _onMounted: ->
    c() for c in @_mountedCallbacks
