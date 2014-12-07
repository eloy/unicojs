class UnicoInstance
  constructor: (@app, @ctrl, @el) ->
    @ctx = new UnicoContext(@app, @ctrl)

    # Extract meta from the element
    @metaRoot = new MetaElement(@ctx, @el)
    @reactClass = ReactFactory.buildClass @metaRoot, @ctx
    @reactElement = React.createElement(@reactClass)
    @reactRender = React.render @reactElement, @el

    # @translate()
    # @ctx.addChangeListener => @refresh()
    # @refresh()

  # refresh: ->
  #   @reactRender.setProps @ctx.props()
  #   return true

  # buildReactClass: ->
  #   root = @metaRoot
  #   @reactClass = React.createClass displayName: "Version", render: ->
  #     nodes = nodes2react root.nodes, ctx, @
  #     elements = [root.attrs].concat nodes
  #     React.DOM[root.tag].apply(null, elements)
