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
    # HTML Elements
    if meta.nodes?
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
