class UnicoInstance
  constructor: (@app, ctrlNameOrInstance, @reactRender, @params={}) ->
    @ctx = new UnicoContext(@, ctrlNameOrInstance)
    @ctx.addChangeListener => @refresh()
    @contents = {}

  build: (@el) ->
    @metaRoot = new MetaElement(@ctx, @el)
    @reactClass = ReactFactory.buildClass @metaRoot, @ctx
    @reactElement = React.createElement(@reactClass)
    @reactRender = ReactDOM.render @reactElement, @el


  buildRoute: (request, path) ->
    partialPromise = @app.tmplFactory.loadTemplate @ctx, request.route.partial
    layout_name = @ctx.ctrl.layout || "application"
    layoutPromise = @app.tmplFactory.loadTemplate @ctx, "/layouts/#{layout_name}.html"

    task = Promise.all [partialPromise, layoutPromise]
    task.then (r) =>
      partial = r[0]
      layout = r[1]
      @contents.main = partial.meta

      targetMeta = new MetaElement @ctx, document.createElement('div')
      targetMeta.nodes = layout.meta.nodes
      @routeMeta = targetMeta
      @reactRender.setProps meta: @routeMeta, ctx: @ctx, =>
        @app._onMounted()
        @app.triggerAfterRender()
      # @refresh()

  refresh: ->
    return false unless @reactRender
    @reactRender.forceUpdate => @app.triggerAfterRender()

    return true

  digest: ->
    @ctx.digest()

  changed: ->
    @ctx.changed()
