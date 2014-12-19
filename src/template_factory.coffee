class TemplateFactory
  constructor: (@opt={}) ->
    @_layouts = {}
    @base = @opt.base || ''

  addLayout: (id, meta) ->
    @_layouts[id] = {meta: meta}


  getLayout: (id) ->
    @_layouts[id]

  loadTemplate: (ctx, id) ->
    if @_layouts[id]
      return Promise.resolve @_layouts[id]
    url = @base + id
    SendRequest.get(url).then (content) =>
      html = "<script type=\"text/html\" id=\"#{id}\">\n#{content.trim()}\n</script>"
      meta = MetaElement.fromStr(ctx, html)
      l = {html: content, meta: meta}
      @_layouts[id] = l
      return l
