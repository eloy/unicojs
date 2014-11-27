html2react = (el, ev) ->
  nodes = []
  for child in el.contents()
    tagName = $(child).prop('tagName')?.toLowerCase()
    attrs = {}

    if tagName && child.attributes.length > 0
      attr_length = child.attributes.length - 1
      for i in [0..attr_length]
        key = child.attributes[i].name
        value = child.attributes[i].value

        key = "className" if key == "class"
        attrs[key] = value

    if tagName && $(child).children().length > 0
      childNodes = html2react $(child, ev)
      elements = [attrs].concat childNodes
      nodes.push React.DOM[tagName].apply(null, elements)
    else
      if tagName
        nodes.push React.DOM[tagName] attrs, $(child).html()
      else
        nodes.push child.textContent
  return nodes

class UnicoEvaluator
  constructor: (@ctrl) ->
    @keys = []
    @values = []
    @extractParams()

  extractParams: ->
    for k, v of @ctrl
      @keys.push k
      @values.push v

  eval: (str) ->
    try
      cmd = "return #{str};"
      args = @keys.concat [cmd]
      func = Function(@keys, cmd)
      return func.apply(null, @values)
    catch
      return ""

class UnicoInstance
  constructor: (@ctrl, @el) ->
    @ev = new UnicoEvaluator(@ctrl)
    @html = @el.html()
    @translate()
    @refresh()

  refresh: ->
    React.renderComponent @reactClass(), @el[0]

  translate: ->
    tagName = @el.prop('tagName').toLowerCase()
    @reactClass = React.createClass displayName: "Version", render: =>
      nodes = html2react $("<html><body><#{tagName}>#{@interpolate(@html)}</#{tagName}></body></html>"), @ev
      elements = [null].concat nodes
      React.DOM[tagName].apply(null, elements)



  interpolate: (html) ->
    html.replace /{{(.+)}}/g, (match, capture) =>
      @ev.eval capture

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
