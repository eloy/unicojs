class ModelDirective
  beforeRender: ->
    @meta.attrs.value = @ctx.eval(@meta.attrs.model)

  build: (ctx, meta) ->
    @ctx = ctx
    @meta = meta

    if meta.tag == "input" && meta.attrs.type == "radio"
      @radio = true
      @attachRadioButton(ctx, meta)
    else if meta.tag == "input" && meta.attrs.type == "checkbox"
      @attachCheckBox(ctx, meta)
    else if meta.tag == "input" && meta.attrs.type == "file"
      @attachFile(ctx, meta)

    else
      @attachValueLink(ctx, meta)

  # Default Value Link
  #----------------------------------------------------------------------

  attachValueLink: (ctx, meta) ->
    meta.attrs.value = ctx.eval(meta.attrs.model)
    meta.attrs.onChange = (event) ->
      value = event.currentTarget.value
      if meta.tag == "input" && meta.attrs.type == "number"
        value = parseInt(value)
      ctx.set meta.attrs.model, value
      ctx.instance.changed()
      return true



  # Check Box
  #----------------------------------------------------------------------

  attachCheckBox: (ctx, meta) ->
    meta.attrs.checkedLink = {
      value: (ctx.eval(meta.attrs.model) == true)

      requestChange: (value) ->
        ctx.set meta.attrs.model, value
        ctx.instance.changed()
        return true
    }


  # File
  #----------------------------------------------------------------------

  attachFile: (ctx, meta) ->
    meta.attrs.onChange = (event) ->
      files = event.target.files
      ctx.set meta.attrs.model, files
      ctx.instance.changed()

  # Radio Button
  #----------------------------------------------------------------------

  # http://stackoverflow.com/a/25413172/1454862
  attachRadioButton: (ctx, meta) ->
    # Name attribute is mandatory
    meta.attrs.name ||= meta.attrs.model

    meta.attrs.onChange = (ev) ->
      input = ev.currentTarget
      valueSrc = input.getAttribute 'value'
      value = ctx.interpolate valueSrc
      ctx.set meta.attrs.model, value

      ctx.instance.changed()
      return true

  beforeRender: ->
    return true unless @radio
    checked = @ctx.eval(@meta.attrs.model) == @ctx.interpolate(@meta.attrs.value)
    @meta.attrs.checked = checked

  link: (ctx, el, meta) ->


UnicoApp.builtInDirectives['model'] = ModelDirective
