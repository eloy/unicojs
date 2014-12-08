class ModelDirective
  build: (ctx, meta) ->
    meta.attrs.valueLink = {
      value: ctx.eval(meta.attrs.model)
      requestChange: (v) ->
        value = v
        value = "'#{value}'" unless typeof(n) == "number"
        exp = "#{meta.attrs.model} = #{value}"
        ctx.eval exp

        # UGLY HACK
        # Sometimes when updating values from the controller we need
        # to append the this prefix. That doesn't happens with values
        # in the scope, need to figure out. So the solution is ask for
        # the value after set without the prefix. If the value doesn't
        # change, then try again with the prefix

        if ctx.eval(meta.attrs.model) != v
          exp = "this.#{meta.attrs.model} = #{value}"
          ctx.eval exp

        ctx.instance.changed()
        return true
    }


UnicoApp.builtInDirectives ||= {}
UnicoApp.builtInDirectives['model'] = ModelDirective
