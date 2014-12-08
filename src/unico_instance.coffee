class UnicoInstance
  constructor: (@app, @ctrl, @el) ->
    @ctx = new UnicoContext(@, @ctrl)

    # Extract meta from the element
    @metaRoot = new MetaElement(@ctx, @el)
    @reactClass = ReactFactory.buildClass @metaRoot, @ctx
    @reactElement = React.createElement(@reactClass)
    @reactRender = React.render @reactElement, @el

  refresh: ->
    @reactRender.setProps()
    return true
