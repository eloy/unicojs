class UnicoEvaluator
  constructor: (@ctrl, @scope=false) ->
    @keys = []
    @values = []
    @_watchExpressions = {}
    @_changeListeners = []
    @_childsScopes = []
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

  buildCallbacks: (attrs) ->
    if attrs['click']
      attrs['onClick'] = =>
        ret = @eval attrs['click']
        @_digest()
        return ret


  # Return a new evalutor with a copy of this, plus the given scope.
  # Used for each loops
  child: (scope) ->
    childEv = new UnicoEvaluator @ctrl, scope
    @_childsScopes.push childEv
    childEv

  # Check if the given string contains expressions. If so, store that
  # expressions for digest and return true. Return false if not
  # expression found
  watch: (str) ->
    str.match(/{{.+}}/) != null

  _digest: ->
    @_triggerChange() if @_changed()

  # Return true if some value change Whenever the view evaluate an
  # expression, we store the returned value.  With this function we
  # evaluate every expression in this context or childrens and return
  # true as soon as we found a diffrence
  _changed: ->
    for exp, old of @_watchExpressions
      newValue = @evalexp
      return true if newValue != old
    for c in @_childsScopes
      return true if c.changed()
    return false

  addChangeListener: (callback) ->
    @_changeListeners.push callback

  _extractParams: (ctx) ->
    for k, v of ctx
      @keys.push k
      if typeof(v) == "function"
        @values.push @_buildFunctionProxy k, v, @ctrl
      else
        @values.push v


  _buildFunctionProxy: (k, v, ctrl) ->
    () -> v.apply ctrl, arguments

  _triggerChange: ->
    for callback in @_changeListeners
      callback()

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

dom2nodes = (el, ev) ->
  nodes = []
  for child in el.contents()
    tagName = $(child).prop('tagName')?.toLowerCase()
    attrs = extractAttributes(child)

    if tagName && attrs.repeat?
      exp = attrs.repeat.match(/([\w\d_\$]+)\s?,?\s?([\w\d_\$]+)?\s+in\s+([\w\d_\(\)\$\[\]\.]+)/)
      keyName = exp[1]
      valueName = exp[2]
      collectionExpression = exp[3]
      childNodes = dom2nodes $(child), ev
      nodes.push { tag: tagName, attrs: attrs, nodes: childNodes, repeat: {keyName: keyName, valueName: valueName, collectionExpression: collectionExpression} }

    # If node has childs, deep into
    else if tagName && $(child).children().length > 0
      childNodes = dom2nodes $(child), ev
      nodes.push { tag: tagName, attrs: attrs, nodes: childNodes }
    else
      if tagName
        value = $(child).val() || $(child).html()
        nodes.push { tag: tagName, attrs: attrs, value: value, evaluate: ev.watch(value) }
      else
        value = child.textContent
        if value.trim().length > 0
          nodes.push { text: value, evaluate: ev.watch(value) }

  return nodes

nodes2react = (nodes, ev) ->
  el = []
  for node in nodes

    # Build callbacks
    ev.buildCallbacks node.attrs if node.attrs

    if node.repeat?
      collection = ev.eval node.repeat.collectionExpression
      if collection instanceof Array
        for item in collection
          scope = {}
          scope[node.repeat.keyName] = item
          reactNodes = nodes2react node.nodes, ev.child(scope)
          el.push React.DOM[node.tag] node.attrs, reactNodes

    # Node with childrens
    else if node.nodes && node.nodes.length > 0
      reactNodes = nodes2react node.nodes, ev
      el.push React.DOM[node.tag] node.attrs, reactNodes

    # Node without childrens
    else if node.tag
      if node.evaluate
        value = ev.interpolate node.value
      else
        value = node.value
      el.push React.DOM[node.tag] node.attrs, value

    # Text Node
    else if node.text?
      if node.evaluate
        value = ev.interpolate(node.text)
      else
        value = node.text
      el.push value
  return el

class UnicoInstance
  constructor: (@ctrl, @el) ->
    @ev = new UnicoEvaluator(@ctrl)
    @html = @el.html()
    @rootNode = @parseDOM()
    @translate()
    @ev.addChangeListener => @refresh()
    @refresh()

  refresh: ->
    React.renderComponent @reactClass(), @el[0]

  translate: ->
    # TODO: check if root is text
    root = @rootNode
    ev = @ev
    @reactClass = React.createClass displayName: "Version", render: ->
      nodes = nodes2react root.nodes, ev
      elements = [root.attrs].concat nodes
      React.DOM[root.tag].apply(null, elements)


  parseDOM: ->
    tagName = @el.prop('tagName').toLowerCase()
    attrs = extractAttributes(@el)
    nodes = dom2nodes(@el, @ev)
    { tag: tagName, attrs: attrs, nodes: nodes }


# Main app
#----------------------------------------------------------------------

class UnicoApp
  constructor: ->
    @controllers = {}

  addController: (name, clazz) ->
    @controllers[name] = clazz


  render: ->
    @instances = []
    # Search for controllers
    for el in $("[controller]")
      name = $(el).attr 'controller'
      clazz = @controllers[name]
      ctrl = new clazz()
      @instances.push new UnicoInstance ctrl, $(el)
  refresh: ->
    for instance in @instances
      instance.refresh()
    true
window.UnicoApp = UnicoApp
