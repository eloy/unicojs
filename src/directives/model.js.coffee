class ModelDirective
  build: (ctx, meta) ->
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
    meta.attrs.valueLink = {
      value: ctx.eval(meta.attrs.model)

      requestChange: (value) ->
        if meta.tag == "input" && meta.attrs.type == "number"
          value = parseInt(value)
        ctx.set meta.attrs.model, value
        ctx.instance.changed()
        return true
    }


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



  link: (ctx, el, meta) ->
    return unless @radio
    if ctx.eval(meta.attrs.model) == ctx.interpolate(meta.attrs.value)
      el.setAttribute 'checked', 'checked'

UnicoApp.builtInDirectives['model'] = ModelDirective
