class UnicoEvaluator
  constructor: (@ctrl, @scope=false) ->
    @keys = []
    @values = []
    @extractParams(@ctrl)
    @extractParams(@scope) if @scope

  extractParams: (ctx) ->
    for k, v of ctx
      @keys.push k
      if typeof(v) == "function"
        @values.push @buildFunctionProxy k, v, @ctrl
      else
        @values.push v

  interpolate: (html) ->
    html.replace /{{(.+)}}/g, (match, capture) =>
      @eval capture

  eval: (str) ->
    try
      cmd = "return #{str};"
      args = @keys.concat [cmd]
      func = Function(@keys, cmd)
      return func.apply(@ctrl, @values)
    catch error
      console.error error
      return ""

  child: (scope) ->
    new UnicoEvaluator @ctrl, scope

  buildFunctionProxy: (k, v, ctrl) ->
    () ->
      v.call ctrl, arguments


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

requireEvaluator = (str) ->
  str.match(/{{.+}}/) != null

dom2nodes = (el) ->
  nodes = []
  for child in el.contents()
    tagName = $(child).prop('tagName')?.toLowerCase()
    attrs = extractAttributes(child)

    if tagName && attrs.repeat?
      exp = attrs.repeat.match(/([\w\d_\$]+)\s?,?\s?([\w\d_\$]+)?\s+in\s+([\w\d_\(\)\$\[\]\.]+)/)
      keyName = exp[1]
      valueName = exp[2]
      collectionExpression = exp[3]
      childNodes = dom2nodes $(child)
      nodes.push { tag: tagName, attrs: attrs, nodes: childNodes, repeat: {keyName: keyName, valueName: valueName, collectionExpression: collectionExpression} }

    # If node has childs, deep into
    else if tagName && $(child).children().length > 0
      childNodes = dom2nodes $(child)
      nodes.push { tag: tagName, attrs: attrs, nodes: childNodes }
    else
      if tagName
        value = $(child).val() || $(child).html()
        evaluate = requireEvaluator value
        nodes.push { tag: tagName, attrs: attrs, value: value, evaluate: evaluate }
      else
        value = child.textContent
        if value.trim().length > 0
          evaluate = requireEvaluator value
          nodes.push { text: value, evaluate: evaluate }

  return nodes

buildCallbacks = (attrs, ev) ->
  if attrs['click']
    attrs['onClick'] = ->
      ev.eval attrs['click']


nodes2react = (nodes, ev) ->
  el = []
  for node in nodes

    # Build callbacks
    buildCallbacks node.attrs, ev if node.attrs

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
    nodes = dom2nodes(@el)
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
