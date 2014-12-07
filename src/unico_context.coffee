class UnicoContext
  constructor: (@app, @ctrl, @scope=false, @opt={}) ->
    @_watchExpressions = {}
    @_changeListeners = []
    @_childsScopes = []


  # Return a new evalutor with a copy of this, plus the given scope.
  # Used for each loops
  child: (scope, opt={}) ->
    # Build a childController with the content of this controller
    # including parent context and parent of parent context
    scopeCtrl = {}
    p = @_extractParams()
    for key, index in p.keys
      scopeCtrl[key] = p.values[index]

    childEv = new UnicoContext @app, scopeCtrl, scope, opt
    @_childsScopes.push childEv
    childEv

  # interpolate: (html) ->
  #   html.replace /{{([\s\w\d\[\]_\(\)\.\$"']+)}}/g, (match, capture) =>
  #     @eval capture


  # eval: Evaluate expressions
  #----------------------------------------------------------------------

  eval: (expression) ->
    p = @_extractParams()
    try
      # Execute expression
      cmd = "return #{expression};"
      args = p.keys.concat [cmd]
      func = Function(p.keys, cmd)
      value = func.apply(@ctrl, p.values)
      return value
    catch error
      console.error(error.stack) if @app.debug
      return null

  # Extract elements in the context and store it in arrays for keys and values
  _extractParams: ->
    keys = []
    values = []
    for ctx in [@ctrl, @scope]
      for k, v of ctx
        keys.push k
        if typeof(v) == "function"
          values.push @_buildFunctionProxy k, v, @ctrl
        else
          values.push v
    return keys: keys, values: values

  # Create functions used in the evaluator.
  # Simplify sintax and emulate functions called in the controller scope
  # For example, we can use foo() and it will execute ctrl.foo()
  _buildFunctionProxy: (k, v, ctrl) ->
    () -> v.apply ctrl, arguments



  # # Create callbacks attached to React elements at render time
  # buildCallbacks: (attrs) ->
  #   if attrs['click']
  #     attrs['onClick'] = =>
  #       ret = @eval attrs['click']
  #       @_digest()
  #       return ret


  # # Inspect the node for directives at inspection time
  # buildNode: (node) ->
  #   if node.content? && @watch node.content
  #     # At this point, we break the conten into an array of strings
  #     # and object, so "ola {{ke}} ase" will be transformed to ["ola
  #     # ", exp_id, " ase"]
  #     if @opt.repeat
  #       node.interpolate = true
  #     else
  #       node.interpolate = @_splitInterpolated node.content

  #   @_attachDirectives node
  #   node



  # # Check if the given string contains expressions. If so, store that
  # # expressions for digest and return true. Return false if not
  # # expression found
  # watch: (str) ->
  #   str.match(/{{.+}}/) != null


  # props: ->
  #   p = {}
  #   for exp, data of @_watchExpressions
  #     # Cache last value for digest later
  #     data.value = @eval(exp)
  #     p[data.property] = data.value
  #   return p

  # propertyId: (exp) ->
  #   if @opt.repeat
  #     exp = @_watchExpressions[exp]
  #     return false unless exp
  #   else
  #     exp = @_watchExpressions[exp] ||= { property: newID() }
  #   exp.property


  # changed:  ->
  #   @_triggerChange()

  # _digest: ->
  #   @_triggerChange() if @_hasChanged()

  # # Return true if some value change Whenever the view evaluate an
  # # expression, we store the returned value.  With this function we
  # # evaluate every expression in this context or childrens and return
  # # true as soon as we found a diffrence
  # _hasChanged: ->
  #   for exp, old of @_watchExpressions
  #     newValue = @ctxalexp
  #     return true if newValue != old
  #   for c in @_childsScopes
  #     return true if c.changed()
  #   return false

  # addChangeListener: (callback) ->
  #   @_changeListeners.push callback

  # _generateID: ->
  #   @counter ||= 0
  #   @counter += 1



  # # Send an event to listeners with a change notification
  # _triggerChange: ->
  #   for callback in @_changeListeners
  #     callback()

  # # Search for directives and initialize'em at inspection time
  # _attachDirectives: (node) ->
  #   for key, value of node.attrs
  #     if @app.directives[key]?
  #       node.directives ||= []
  #       node.directives.push(new @app.directives[key]())

  #   # If node has no directives, we are done
  #   return false unless node.directives?

  #   node.attrs['key'] ||= @_generateID()
  #   # Init directives if init present
  #   for d in node.directives
  #     d.init(@, node) if d.init?

  #   return true


  # _splitInterpolated: (content) ->
  #   childs = []
  #   lastPos = 0
  #   content.replace /{{([\s\w\d\[\]_\(\)\.\$"']+)}}/g, (match, capture, pos) =>
  #     if pos > lastPos
  #       childs.push {t: "text", v: content.substr(lastPos, pos - lastPos)}

  #     # Update lastPos
  #     lastPos = pos + match.length
  #     childs.push {t: "exp", v: capture, property: @propertyId(capture)}

  #   childs
