class MetaElement
  constructor: (@el) ->
    if @el.tagName
      @tag = @el.tagName.toLowerCase()
      @attrs = @_extractAttributes(@el)
      nodes = @extractChildrens(@el)
      @nodes = nodes if nodes.length > 0

    # Set data and interpolation
    @data = @el.data || @el.textContent

    if @data && @data.match(/{{.+}}/) != null
      @interpolate = @_splitInterpolated(@data)

  extractChildrens: (parent) ->
    nodes = []
    for el in parent.childNodes
      nodes.push new MetaElement(el)
    return nodes

  # Transform html attributes into a hash
  _extractAttributes: (el) ->
    attrs = {}
    # Return an empty hash if element has no attributes
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



  _splitInterpolated: (content) ->
    childs = []
    lastPos = 0
    content.replace /{{([\s\w\d\[\]_\(\)\.\$"']+)}}/g, (match, capture, pos) =>
      if pos > lastPos
        childs.push {t: "text", v: content.substr(lastPos, pos - lastPos)}

      # Update lastPos
      lastPos = pos + match.length
      childs.push {t: "exp", v: capture}

    childs
