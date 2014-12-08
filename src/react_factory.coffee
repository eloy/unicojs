ReactFactory =
  buildClass: (meta, ctx) ->
    React.createClass render: ->
      ReactFactory.buildElement meta, ctx

  buildNodes: (nodes, ctx) ->
    r = []
    for meta in nodes
      r.push @buildElement meta, ctx
    return r

  buildElement: (meta, ctx) ->
    # Text elements
    if meta.text
      return @buildTextElement meta, ctx

    if meta.repeat
      content = @_buildRepeatNodes meta, ctx
    # HTML Elements
    else if meta.nodes?
      content =  @buildNodes meta.nodes, ctx
    else
      content = meta.data
    return React.DOM[meta.tag] meta.attrs, content


  buildTextElement: (meta, ctx) ->
    return meta.data unless  meta.interpolate?
    nodes = []
    for exp in meta.interpolate
      if exp.t == 'text'
        nodes.push exp.v
      else
        nodes.push ctx.eval(exp.v)
    return nodes


  _buildRepeatNodes: (meta, ctx) ->
    nodes = []
    src = ctx.eval meta.repeatExp.src
    if src instanceof Array
      for v in src
        scope = {}
        scope[meta.repeatExp.value] = v
        childCtx = ctx.child scope
        childNodes = Object.create(meta.nodes)
        nodes.push @buildNodes childNodes, childCtx

    else
      for k,v of src
        scope = {}
        scope[meta.repeatExp.value] = v
        if meta.repeatExp.key
          scope[meta.repeatExp.key] = k
        childCtx = ctx.child scope
        childNodes = Object.create(meta.nodes)
        nodes.push @buildNodes childNodes, childCtx

    return nodes
