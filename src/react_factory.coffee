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

    # html comments
    if meta.tag == "comment"
      return null

    # prepare meta for rendering. This initialize directives and call
    # buid on them
    meta.prepareIgnition ctx

    # Hide elements if attribute hide is true retuning null
    if meta.attrs.hide
      if typeof(meta.attrs.hide) == 'function'
        return null if meta.attrs.hide(ctx)
      else
        return null

    if meta.reactClass
      # Duplicate current meta and remove the class to avoid infinete loop
      metaDup = meta.clone()
      metaDup.reactClass = false
      return React.createElement meta.reactClass, {meta: metaDup, ctx: ctx}

    # If it is a repeat element
    if meta.repeatExp
      content = @_buildRepeatNodes meta, ctx

    # Template placeholder
    else if meta.attrs.template
      tmpl = ctx.instance.templates[meta.attrs.template]
      content = if tmpl then @buildNodes(tmpl.nodes, ctx) else []

    # Content. Content is used as placeholders in layouts. In the
    # application layout you add elements with the attribute content
    # and in the UnicoInstance, you can set meta into the contents
    # object with using as key the name used in the attrute content
    # TODO: better name?
    else if meta.attrs.content
      if ctx.instance.contents && c = ctx.instance.contents[meta.attrs.content]
        content = @buildNodes(c.nodes, ctx)
      else
        content = []

    # Component
    else if meta.component
      childCtx = ctx.child meta.component.directive.instance
      if meta.component.template
        return @buildElement meta.component.template, childCtx
      else if meta.nodes
        content = @buildNodes meta.nodes, childCtx


    # HTML Element with childrens
    else if meta.nodes
      content =  @buildNodes meta.nodes, ctx

    # Single element
    else
      content = meta.data

    # Transform to div if tag is invalid
    unless React.DOM[meta.tag]
      meta.originalTag = meta.tag
      meta.tag = 'div'
      meta.attrs['data-original-tag'] = meta.originalTag

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
      last = src.length - 1
      for v, index in src
        scope = {"$index": index, "$first": index == 0, "$last": index == last}
        scope[meta.repeatExp.value] = v
        childCtx = ctx.child scope
        childNodes = meta.nodes.map (m) -> m.clone()
        nodes.push @buildNodes childNodes, childCtx

    else
      for k,v of src
        scope = {}
        scope[meta.repeatExp.value] = v
        if meta.repeatExp.key
          scope[meta.repeatExp.key] = k
        childCtx = ctx.child scope
        childNodes = meta.nodes.map (m) -> m.clone()
        nodes.push @buildNodes childNodes, childCtx

    return nodes
