class UnicoInstance
  constructor: (@app, ctrlNameOrInstance) ->
    @ctx = new UnicoContext(@, ctrlNameOrInstance)
    @ctx.addChangeListener => @refresh()
    @contents = {}



    # Extract meta from the element
  build: (@el) ->
    @metaRoot = new MetaElement(@ctx, @el)
    @reactClass = ReactFactory.buildClass @metaRoot, @ctx
    @reactElement = React.createElement(@reactClass)
    @reactRender = React.render @reactElement, @el


  buildRoute: (request, path, body) ->
    partialPromise = @app.tmplFactory.loadTemplate @ctx, request.route.layout
    layoutPromise = @app.tmplFactory.loadTemplate @ctx, '/layouts/application.html'

    task = Promise.all [partialPromise, layoutPromise]
    task.then (r) =>
      partial = r[0]
      layout = r[1]
      @contents.main = partial.meta

      targetMeta = new MetaElement @ctx, document.createElement('body')
      targetMeta.nodes = layout.meta.nodes
      reactClass = ReactFactory.buildClass targetMeta, @ctx

      reactElement = React.createElement(reactClass)
      # Unmount current page
      @reactRender = React.render reactElement, body, (=> @app._onMounted() )


  refresh: ->
    @reactRender.setProps()
    return true

  digest: ->
    @ctx.digest()

  changed: ->
    @ctx.changed()
