class SendRequest
  request = (method, url, data, callback, errorCallback) ->
    r = new XMLHttpRequest()
    r.onreadystatechange = ->
      if r.readyState == r.DONE
        if r.status == 200
          callback(r.responseText)
        else
          error = new Error('Server responded with a status of ' + r.status)
          errorCallback error

    r.open method, url
    r.send(data)

  promise = (method, url, data, callback, errorCallback) ->
    new Promise (fulfill, reject) ->
      success = (data) -> fulfill(data)
      error = (error) -> reject(error)
      request method, url, data, success, error

  @get: (url, data) ->
    promise 'GET', url, data
