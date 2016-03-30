class MouseUpDirective
  build: (ctx, meta) ->
    meta.attrs['onMouseUp'] = (ev) ->
      ev.preventDefault()
      ctx.eval meta.attrs['mouseup']
      ctx.instance.digest()
      return true

UnicoApp.builtInDirectives ||= {}
UnicoApp.builtInDirectives['mouseup'] = MouseUpDirective
