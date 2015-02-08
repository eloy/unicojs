Request = (method, url, data) ->
  request = (method, url, data, callback, errorCallback) ->
    r = new XMLHttpRequest()
    r.onreadystatechange = ->
      if r.readyState == 4
        if r.status == 200
          callback(r.responseText)
        else
          error = new Error('Server responded with a status of ' + r.status)
          errorCallback error

    r.open method, url

    # Send data as JSON encoded
    if method != 'GET' && data
      r.setRequestHeader('Content-type','application/json; charset=utf-8')
      data = JSON.stringify(data)

    r.send(data)

  new Promise (fulfill, reject) ->
    success = (resp) -> fulfill(resp)
    error = (error) -> reject(error)
    request method, url, data, success, error


bindResult = (promise, res) ->
  if res instanceof Array
    Array::push.apply(promise, res)
  else
    promise[k] = v for k,v of res


Model = (base, opt={}) ->
  buildUrl = (base, params) ->
    url = base.replace /:([\w_-]+)/g, (match, capture) ->
      if params[capture] == undefined then '' else params[capture]

    url = url.replace /\/\//g, '/'
    url = url.slice(0, -1) if url.substr(-1,1) == '/'
    return url

  buildPromise = (promise) ->
    unless opt.format == 'plain'
      promise = promise.then (data) ->
        try
          return JSON.parse(data)
        catch
          return data

    promise = promise.then (res) ->
      bindResult promise, res
      return res

    return promise

  index: (params={}, data={}) -> @get(params, data)
  get: (params={}, data={}) ->
    url = buildUrl base, params

    # add arguments
    args = []
    args.push("#{k}=#{v}") for k,v of data
    unless args.length == 0
      url += "?" + args.join("&")

    promise = Request('GET', url)
    return buildPromise(promise)

  put: (params={}, data) ->
    url = buildUrl base, params
    promise = Request('PUT', url, data)
    return buildPromise(promise)

  post: (params={}, data) ->
    url = buildUrl base, params
    promise = Request('POST', url, data)
    return buildPromise(promise)

  delete: (params={}) ->
    url = buildUrl base, params
    promise = Request('DELETE', url)
    return buildPromise(promise)
