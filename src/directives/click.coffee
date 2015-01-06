class ClickDirective
  build: (ctx, meta) ->
    meta.attrs['onClick'] = (ev) ->
      ev.preventDefault()
      ctx.eval meta.attrs['click']
      ctx.instance.digest()
      return true

UnicoApp.builtInDirectives ||= {}
UnicoApp.builtInDirectives['click'] = ClickDirective
