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

    # prepare meta for rendering. This initialize directives and call
    # buid on them
    meta.prepareIgnition ctx

    # Hide elements if attribute hide is true retuning null
    return null if meta.attrs.hide

    if meta.reactClass
      # Duplicate current meta and remove the class to avoid infinete loop
      metaDup = Object.create(meta)
      metaDup.reactClass = false
      return React.createElement meta.reactClass, {meta: metaDup, ctx: ctx}

    if meta.repeat
      content = @_buildRepeatNodes meta, ctx
    # HTML Elements
    else if meta.nodes?
      content =  @buildNodes meta.nodes, ctx
    else
      content = meta.data

    # Finally, return the react element
    return React.DOM[meta.tag] meta.attrs, content



  buildTextElement: (meta, ctx) ->
    return meta.data unless  meta.interpolate?
    nodes = []
    for exp in meta.interpolate
      if exp.t == 'text'
        nodes.push exp.v
      else
        nodes.push ctx.evalAndWatch(exp.v)
    return nodes


  _buildRepeatNodes: (meta, ctx) ->
    nodes = []
    src = ctx.evalAndWatch meta.repeatExp.src
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
