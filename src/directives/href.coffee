class HrefDirective
  build: (ctx, meta) ->
    return true unless ctx.app.router

    # Ignore this attribute if it already implements other listeners
    return true if meta.attrs.click

    meta.attrs['onClick'] = (ev) ->
      url = ev.nativeEvent.currentTarget.activeElement.attributes.href.value
      return true if !!url.match(/^[\w]+:\/\//)
      ev.preventDefault()
      ctx.app.visit url

UnicoApp.builtInDirectives['href'] = HrefDirective
