class UnicoContext
  constructor: (@instance, @ctrl, @scope=false, @opt={}) ->
    @app = @instance.app
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

    childEv = new UnicoContext @instance, scopeCtrl, scope, opt
    @_childsScopes.push childEv
    childEv

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

  # Search and replace expressions in the given text
  interpolate: (html) ->
    html.replace /{{([\s\w\d\[\]_\(\)\.\$"']+)}}/g, (match, capture) =>
      @eval capture


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
