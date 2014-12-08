class ClickDirective
  build: (ctx, meta) ->
    meta.attrs['onClick'] = ->
      ret = ctx.eval meta.attrs['click']
      ctx.instance.digest()
      return ret

UnicoApp.builtInDirectives ||= {}
UnicoApp.builtInDirectives['click'] = ClickDirective
