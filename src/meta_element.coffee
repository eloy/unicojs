class MetaElement
  constructor: (@ctx, el) ->
    @_extractMeta el
    @_denormalizeRepeat()
    @_attachDirectives()


  _extractMeta: (el) ->
    if el.tagName
      @tag = el.tagName.toLowerCase()
      @attrs = @_extractAttributes(el)
      nodes = @_extractChildrens(el)
      @nodes = nodes if nodes.length > 0
    else
      @text = true
      @data = el.data if el.data?.trim().length > 0
      if @data && @data.match(/{{.+}}/) != null
        @interpolate = @_splitInterpolated(@data)

  # Extrac nodes from the given element
  _extractChildrens: (parent) ->
    nodes = []
    for el in parent.childNodes
      meta = new MetaElement(@ctx, el)
      nodes.push meta if meta._isValid()
    return nodes

  # Transform html attributes into a hash
  _extractAttributes: (el) ->
    attrs = {}
    # Return an empty hash if element has no attributes
    return attrs unless el.attributes and el.attributes.length > 0

    length = el.attributes.length - 1
    for i in [0..length]
      key = el.attributes[i].name
      value = el.attributes[i].value

      # Do some transformations for react
      key = "className" if key == "class"

      # Assign the value
      attrs[key] = value

    return attrs

    # Return an array with text contstants and variables interpolated
  _splitInterpolated: (content) ->
    childs = []
    lastPos = 0
    content.replace /{{([\s\w\d\[\]_\(\)\.\$"']+)}}/g, (match, capture, pos) =>
      if pos > lastPos
        childs.push {t: "text", v: content.substr(lastPos, pos - lastPos)}

      # Update lastPos
      lastPos = pos + match.length
      childs.push {t: "exp", v: capture}

    # Add the end
    if lastPos < content.length
      childs.push {t: "text", v: content.substr(lastPos, content.length - lastPos)}

    return childs


  _isValid: ->
    @tag || @data

  # Called just before create the reactElement.
  prepareIgnition: (ctx) ->
    if @directives?
      # Instantiate directives and call build if present
      for d in @directives
        d.instance = new d.clazz()
        d.instance.build(ctx, @) if d.instance.build?

  # Search for directives and initialize'em at inspection time
  _attachDirectives:  ->
    return unless @attrs
    for key, value of @attrs
      if @ctx.app.directives[key]?
        @directives ||= []
        @directives.push { clazz: @ctx.app.directives[key] }

    return unless @directives?

    # Create reactClass
    renderCallback = -> ReactFactory.buildElement @props.meta, @props.ctx
    mountedCallback = ->
      for d in @props.meta.directives
        if d.instance?.link
          d.instance.link @props.ctx, @getDOMNode(), @props.meta

    @reactClass = React.createClass componentDidMount: mountedCallback, render: renderCallback


  # Denormalize expression from collection in form
  # "value in items()" or "key, value in items()
  _denormalizeRepeat: ->
    return unless @attrs?.repeat
    exp = @attrs.repeat.match(/([\w\d_\$]+)\s?,?\s?([\w\d_\$]+)?\s+in\s+([\s\w\d\[\]_\(\)\.\$"']+)/)
    return unless exp
    exp_1 = exp[1]
    exp_2 = exp[2]
    collectionExpression = exp[3]
    @repeat = true
    @repeatExp = {src: collectionExpression}

    if exp_2
      @repeatExp.key = exp_1
      @repeatExp.value = exp_2
    else
      @repeatExp.value = exp_1
