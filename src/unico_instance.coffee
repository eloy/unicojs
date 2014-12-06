class UnicoInstance
  constructor: (@app, @ctrl, @el) ->
    @ctx = new UnicoContext(@app, @ctrl)

    # Extract meta from the element
    @metaRoot = new MetaElement(@el)
    # @translate()
    # @ctx.addChangeListener => @refresh()
    # @refresh()

  # refresh: ->
  #   @reactRender.setProps @ctx.props()
  #   return true

  # translate: ->
  #   # TODO: check if root is text
  #   root = @rootNode
  #   ctx = @ctx
  #   @reactClass = React.createClass displayName: "Version", render: ->
  #     nodes = nodes2react root.nodes, ctx, @
  #     elements = [root.attrs].concat nodes
  #     React.DOM[root.tag].apply(null, elements)
  #   @reactRender = React.renderComponent @reactClass(@ctx.props()), @el[0]
