class IfDirective

  build: (ctx, meta)->
    # Watch the expression
    ctx.evalAndWatch(meta.attrs.if)

    meta.attrs.hide = (ctx) ->
      !ctx.eval(meta.attrs.if)

UnicoApp.builtInDirectives['if'] = IfDirective
