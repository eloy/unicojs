# Main app
#----------------------------------------------------------------------

class UnicoApp
  @builtInDirectives = {}

  constructor: (@opt={})->
    @controllers = {}
    @directives = UnicoApp.builtInDirectives
    @components = {}
    @models = {}
    @_mountedCallbacks = []

    if @opt.enableRouter
      @router = @_createRouter()
      @tmplFactory = new TemplateFactory(base: @opt.templateBasePath)

  addController: (name, clazz) ->
    @controllers[name] = clazz

  controllerFromString: (ctrlNameOrInstance) ->
    return ctrlNameOrInstance unless typeof(ctrlNameOrInstance) == 'string'
    @controllers[ctrlNameOrInstance]


  addDirective: (name, clazz) ->
    @directives[name] = clazz

  addComponent: (name, clazz) ->
    @components[name] = clazz

  addModel: (name, base, opt={}) ->
    @models[name] = {base: base, opt: opt}

  model: (name) ->
    conf = @models[name]
    return false unless conf
    Model(conf.base, conf.opt)

  refresh: ->
    if @instances
      i.changed() for i in @instances
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

  buildRender: ->
    body = document.querySelector @opt.targetElement
    reactClass = React.createClass render: ->
      return React.DOM.div( {}, []) unless @props.meta && @props.ctx
      ReactFactory.buildElement @props.meta, @props.ctx

    reactElement = React.createElement(reactClass, {meta: false, ctx: false})
    @reactRender = React.render reactElement, body


  visit: (path) ->
    @router.visit path

  startRouter: ->
    @buildRender()
    @router.start()

  addMountListener: (listener) ->
    @_mountedCallbacks.push listener

  _loadRoute: (request, path) ->
    try
      ctrlName = request.route.controller
      ctrl = @controllerFromString(ctrlName)

      # Run beforeAction methods if present
      if ctrl.beforeAction
        res = ctrl.beforeAction(path, request)
        # Redirect
        return @visit(res.redirect) if res && res.redirect


      instance = new UnicoInstance @, ctrlName, @reactRender, request.params
      @instances = [instance]
      instance.buildRoute request, path

    catch error
      console.error(error.stack) if @debug
      return false

  _createRouter: ->
    router = new UnicoRouter({type: @opt.routerType})
    router.addRouteChangedListener (request, path) =>
      @_loadRoute(request, path)
    @opt.targetElement ||= "body"
    return router

  _onMounted: ->
    c() for c in @_mountedCallbacks

  # cookies
  #----------------------------------------------------------------------
  getCookie: (name) ->
    pattern = RegExp(name + '=.[^;]*')
    matched = document.cookie.match(pattern)
    if matched
      c = matched[0].split('=')
      return c[1]
    false

  deleteCookie: (name) ->
    document.cookie = "#{name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
