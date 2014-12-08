class IfDirective
  build: (ctx, meta)->
    val = ctx.eval meta.attrs.if
    meta.attrs.hide = !val

UnicoApp.builtInDirectives ||= {}
UnicoApp.builtInDirectives['if'] = IfDirective
