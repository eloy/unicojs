describe 'SendRequest', ->
  describe 'get', ->
    describe 'if file not found', ->
      value = undefined
      promise = undefined
      beforeEach (done) ->
        try
          promise = SendRequest.get('invalid')
          promise.then(v) ->
            value = false
            done()
        catch error
          value = true
          done()

      it 'should return a promise', () ->
        expect(value).toBe true

    describe 'valid request', ->
      value = undefined
      promise = undefined
      beforeEach (done) ->
        promise = SendRequest.get('/base/test/fixtures/test.txt')
        promise.then (v) ->
          value = v
          done()

      it 'should return a promise', () ->
        expect(value).toMatch 'Hello World!'
