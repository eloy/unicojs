class ChangeDirective
  build: (ctx, meta) ->
    meta.attrs['onChange'] = (ev) ->
      ev.preventDefault()
      ctx.eval meta.attrs['change']
      ctx.instance.digest()
      return true

UnicoApp.builtInDirectives ||= {}
UnicoApp.builtInDirectives['change'] = ChangeDirective
