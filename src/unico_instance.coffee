class UnicoInstance
  constructor: (@app, ctrlNameOrInstance, @reactRender, @params={}) ->
    @ctx = new UnicoContext(@, ctrlNameOrInstance)
    @ctx.addChangeListener => @refresh()
    @contents = {}

    # Extract meta from the element
  build: (@el) ->
    @metaRoot = new MetaElement(@ctx, @el)
    @reactClass = ReactFactory.buildClass @metaRoot, @ctx
    @reactElement = React.createElement(@reactClass)
    @reactRender = React.render @reactElement, @el


  buildRoute: (request, path) ->
    partialPromise = @app.tmplFactory.loadTemplate @ctx, request.route.layout
    layoutPromise = @app.tmplFactory.loadTemplate @ctx, '/layouts/application.html'

    task = Promise.all [partialPromise, layoutPromise]
    task.then (r) =>
      partial = r[0]
      layout = r[1]
      @contents.main = partial.meta

      targetMeta = new MetaElement @ctx, document.createElement('div')
      targetMeta.nodes = layout.meta.nodes
      @routeMeta = targetMeta
      @refresh()

  refresh: ->
    return false unless @reactRender
    @reactRender.setProps meta: @routeMeta, ctx: @ctx, (=> @app._onMounted() )
    return true

  digest: ->
    @ctx.digest()

  changed: ->
    @ctx.changed()
