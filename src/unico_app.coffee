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
    for instance in @instances
      instance.changed()
    true

  # One Time Render
  #----------------------------------------------------------------------

  render: ->
    @instances = []
    # Search for controllers
    for el in document.querySelectorAll("[controller]")
      name = el.getAttribute 'controller'
      clazz = @controllers[name]
      ctrl = new clazz()
      @instances.push new UnicoInstance @, ctrl, el
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
      ctrlName = request.route.controller
      ctrl = new @controllers[ctrlName]()
      instance = {app: @, contents: {} }
      ctx = new UnicoContext instance, ctrl
      body = document.querySelector @opt.targetElement

      partialPromise = @tmplFactory.loadTemplate ctx, request.route.layout
      layoutPromise = @tmplFactory.loadTemplate ctx, '/layouts/application.html'

      task = Promise.all [partialPromise, layoutPromise]
      task.then (r) =>
        partial = r[0]
        layout = r[1]
        instance.contents.main = partial.meta

        targetMeta = new MetaElement ctx, document.createElement('body')
        targetMeta.nodes = layout.meta.nodes
        reactClass = ReactFactory.buildClass targetMeta, ctx

        reactElement = React.createElement(reactClass)
        # Unmount current page
        reactRender = React.render reactElement, body, (=> @_onMounted() )

    catch err
      console.log error
      return false

  _createRouter: ->
    router = new UnicoRouter()
    router.addRouteChangedListener (request, path) =>
      @_loadRoute(request, path)
    @opt.targetElement ||= "body"
    return router

  _onMounted: ->
    c() for c in @_mountedCallbacks
