class HrefDirective
  build: (ctx, meta) ->
    return true unless ctx.app.router
    meta.attrs['onClick'] = (ev) ->
      ev.preventDefault()
      url = ev.nativeEvent.currentTarget.activeElement.attributes.href.value
      ctx.app.visit url

UnicoApp.builtInDirectives['href'] = HrefDirective
