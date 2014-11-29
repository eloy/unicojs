class UnicoContext
  constructor: (@app, @ctrl, @scope=false) ->
    @keys = []
    @values = []
    @_watchExpressions = {}
    @_changeListeners = []
    @_childsScopes = []
    @_postRenderRequired = []
    @_extractParams(@ctrl)
    @_extractParams(@scope) if @scope
  interpolate: (html) ->
    html.replace /{{(.+)}}/g, (match, capture) =>
      @eval capture

  eval: (expression) ->
    try
      # Execute expression
      cmd = "return #{expression};"
      args = @keys.concat [cmd]
      func = Function(@keys, cmd)
      value = func.apply(@ctrl, @values)

      # Cache value for latest digest
      @_watchExpressions[expression] = value
      return value
    catch error
      console.error error
      return ""

  # Create callbacks attached to React elements at render time
  buildCallbacks: (attrs) ->
    if attrs['click']
      attrs['onClick'] = =>
        ret = @eval attrs['click']
        @_digest()
        return ret


  # Inspect the node for directives at inspection time
  buildNode: (node) ->
    @_attachDirectives node
    node


  # Return a new evalutor with a copy of this, plus the given scope.
  # Used for each loops
  child: (scope) ->
    childEv = new UnicoContext @ctrl, scope
    @_childsScopes.push childEv
    childEv

  # Check if the given string contains expressions. If so, store that
  # expressions for digest and return true. Return false if not
  # expression found
  watch: (str) ->
    str.match(/{{.+}}/) != null


  triggerRender: (reactRender) ->
    for node in @_postRenderRequired
      ref =  reactRender.refs[node.attrs.ref]
      if ref? && el=ref.getDOMNode()
        for d in node.directives
          d.link(@, el)
          node.directiveLinked = true
      else
        @_postRenderRequired.delete node

  _digest: ->
    @_triggerChange() if @_changed()

  # Return true if some value change Whenever the view evaluate an
  # expression, we store the returned value.  With this function we
  # evaluate every expression in this context or childrens and return
  # true as soon as we found a diffrence
  _changed: ->
    for exp, old of @_watchExpressions
      newValue = @ctxalexp
      return true if newValue != old
    for c in @_childsScopes
      return true if c.changed()
    return false

  addChangeListener: (callback) ->
    @_changeListeners.push callback

  _generateID: ->
    @counter ||= 0
    @counter += 1

  _extractParams: (ctx) ->
    for k, v of ctx
      @keys.push k
      if typeof(v) == "function"
        @values.push @_buildFunctionProxy k, v, @ctrl
      else
        @values.push v

  # Create functions used in the evaluator.
  # Simplify sintax and emulate functions called in the controller scope
  # By example, we can use foo() and it will execute ctrl.foo()
  _buildFunctionProxy: (k, v, ctrl) ->
    () -> v.apply ctrl, arguments

  # Send an event to listeners with a change notification
  _triggerChange: ->
    for callback in @_changeListeners
      callback()

  # Search for directives and initialize'em
  _attachDirectives: (node) ->
    for key, value of node.attrs
      if @app.directives[key]?
        node.directives ||= []
        node.directives.push(new @app.directives[key]())

    # If node has no directives, we are done
    return false unless node.directives?

    # Attach reference
    node.attrs['ref'] ||= @_generateID()

    # If node has directives, add it for later process
    @_postRenderRequired.push node

    # Init directives if init present
    for d in node.directives
      d.init(@, node) if d.init?

    return true

extractAttributes = (el) ->
  attrs = {}
  return attrs unless el.attributes and el.attributes.length > 0
  length = el.attributes.length - 1
  for i in [0..length]
    key = el.attributes[i].name
    value = el.attributes[i].value

    # Do some transformations for react
    key = "className" if key == "class"

    # Assign the value
    attrs[key] = value

  return attrs

dom2nodes = (el, ctx) ->
  nodes = []
  for child in el.contents()
    tagName = $(child).prop('tagName')?.toLowerCase()
    attrs = extractAttributes(child)

    if tagName && attrs.repeat?
      exp = attrs.repeat.match(/([\w\d_\$]+)\s?,?\s?([\w\d_\$]+)?\s+in\s+([\w\d_\(\)\$\[\]\.]+)/)
      keyName = exp[1]
      valueName = exp[2]
      collectionExpression = exp[3]
      childNodes = dom2nodes $(child), ctx
      nodes.push ctx.buildNode(tag: tagName, attrs: attrs, nodes: childNodes, repeat: {keyName: keyName, valueName: valueName, collectionExpression: collectionExpression})

    # If node has childs, deep into
    else if tagName && $(child).children().length > 0
      childNodes = dom2nodes $(child), ctx
      nodes.push ctx.buildNode(tag: tagName, attrs: attrs, nodes: childNodes)
    else
      if tagName
        value = $(child).val() || $(child).html()
        nodes.push ctx.buildNode(tag: tagName, attrs: attrs, value: value, evaluate: ctx.watch(value) )
      else
        value = child.textContent
        if value.trim().length > 0
          nodes.push { text: value, evaluate: ctx.watch(value) }

  return nodes


buildReactDOM = (tag, attrs, content) ->
  node = React.DOM[tag] attrs, content
  window.node = node
  return node

nodes2react = (nodes, ctx) ->
  el = []
  for node in nodes

    # Build callbacks
    ctx.buildCallbacks node.attrs if node.attrs

    if node.repeat?
      collection = ctx.eval node.repeat.collectionExpression
      if collection instanceof Array
        for item in collection
          scope = {}
          scope[node.repeat.keyName] = item
          reactNodes = nodes2react node.nodes, ctx.child(scope)
          el.push buildReactDOM node.tag, node.attrs, reactNodes

    # Node with childrens
    else if node.nodes && node.nodes.length > 0
      reactNodes = nodes2react node.nodes, ctx
      el.push buildReactDOM node.tag, node.attrs, reactNodes

    # Node without childrens
    else if node.tag
      if node.evaluate
        value = ctx.interpolate node.value
      else
        value = node.value
      el.push buildReactDOM node.tag, node.attrs, value

    # Text Node
    else if node.text?
      if node.evaluate
        value = ctx.interpolate(node.text)
      else
        value = node.text
      el.push value
  return el

class UnicoInstance
  constructor: (@app, @ctrl, @el) ->
    @ctx = new UnicoContext(@app, @ctrl)
    @html = @el.html()
    @rootNode = @parseDOM()
    @translate()
    @ctx.addChangeListener => @refresh()
    @refresh()
    @ctx.triggerRender(@reactRender)

  refresh: ->
    @reactRender = React.renderComponent @reactClass(), @el[0]
    return true

  translate: ->
    # TODO: check if root is text
    root = @rootNode
    ctx = @ctx
    @reactClass = React.createClass displayName: "Version", render: ->
      nodes = nodes2react root.nodes, ctx
      elements = [root.attrs].concat nodes
      React.DOM[root.tag].apply(null, elements)


  parseDOM: ->
    tagName = @el.prop('tagName').toLowerCase()
    attrs = extractAttributes(@el)
    nodes = dom2nodes(@el, @ctx)
    { tag: tagName, attrs: attrs, nodes: nodes }


# built in directives
#----------------------------------------------------------------------

class ModelDirective
  link: (scope, el) ->
    console.log el


# Main app
#----------------------------------------------------------------------

class UnicoApp
  constructor: ->
    @controllers = {}
    @directives = {}

  addController: (name, clazz) ->
    @controllers[name] = clazz

  addDirective: (name, clazz) ->
    @directives[name] = clazz

  render: ->
    @instances = []
    # Search for controllers
    for el in $("[controller]")
      name = $(el).attr 'controller'
      clazz = @controllers[name]
      ctrl = new clazz()
      @instances.push new UnicoInstance @, ctrl, $(el)
  refresh: ->
    for instance in @instances
      instance.refresh()
    true
window.UnicoApp = UnicoApp
