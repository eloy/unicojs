class MouseDownDirective
  build: (ctx, meta) ->
    meta.attrs['onMouseDown'] = (ev) ->
      ev.preventDefault()
      ctx.eval meta.attrs['mousedown']
      ctx.instance.digest()
      return true

UnicoApp.builtInDirectives ||= {}
UnicoApp.builtInDirectives['mousedown'] = MouseDownDirective
