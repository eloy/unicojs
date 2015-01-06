class SubmitDirective
  build: (ctx, meta) ->
    meta.attrs['onSubmit'] = (ev) ->
      ev.preventDefault()
      ctx.eval meta.attrs['submit']
      ctx.instance.digest()
      return true

UnicoApp.builtInDirectives ||= {}
UnicoApp.builtInDirectives['submit'] = SubmitDirective
