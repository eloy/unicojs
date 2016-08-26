extractField = (ctx, field) ->
  value = ctx.eval(field.value)
  opt = {label: value}
  if field.key
    opt.key = ctx.eval(field.key)
  return opt

evalOptions = (ctx, exp) ->
  options = []
  src = ctx.eval exp.from.src
  if src instanceof Array
    for v, index in src
      scope = {"$index": index}
      scope[exp.from.value] = v
      childCtx = ctx.child scope
      options.push extractField childCtx, exp.field

  else
    for k,v of src
      scope = {}
      scope[exp.from.value] = v
      scope[exp.from.key] = k if meta.repeatExp.key
      childCtx = ctx.child scope
      options.push extractField childCtx, exp.field

  return options

buildSelect = (ctx, meta) ->
  buildOptions: ->
    opt = []

    opt.push React.createElement("option", { key: null, value: null}, "Select one")

    if meta.optionsExp
      options = evalOptions ctx, meta.optionsExp
      for o in options
        key = o.key
        value = if ("value" in o) then o.value else key
        label = o.label
        opt.push React.createElement("option", { key: key, value: value }, label)

    # Add options from markup
    if meta.nodes
      for node in meta.nodes
        opt.push ReactFactory.buildElement node, ctx

    return opt

  onChange: (e) ->
    value = e.target.value
    ctx.set meta.attrs.model, value
    ctx.instance.changed()

  render: ->
    opt = {className: meta.attrs.className}
    if meta.attrs.model
      opt.value = ctx.eval(meta.attrs.model)
      opt.onChange = @onChange

    React.createElement("select", opt, @buildOptions())

class SelectComponent
  build: (ctx, meta, el) ->
    meta.reactClass = React.createClass buildSelect(ctx, meta)

UnicoApp.builtInComponents['select'] = SelectComponent
