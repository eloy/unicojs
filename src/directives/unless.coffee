class UnlessDirective

  build: (ctx, meta)->
    # Watch the expression
    ctx.evalAndWatch(meta.attrs.unless)

    meta.attrs.hide = (ctx) ->
      ctx.eval(meta.attrs.unless)

UnicoApp.builtInDirectives['unless'] = UnlessDirective
