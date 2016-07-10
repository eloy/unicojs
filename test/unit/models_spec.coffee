describe 'models', ->
  describe 'build models', ->
    app = new UnicoApp()
    resp = undefined

    beforeEach (done) ->
      app.addModel 'foo', '/api/foo'
      jasmine.Ajax.install();
      jasmine.Ajax.stubRequest('/api/foo').andReturn responseText: JSON.stringify({foo: 'bar'})
      model = app.model 'foo'
      model.index().then (data) ->
        resp = data
        done()

    it 'should build valid models', ->
      expect(resp).toEqual {foo: 'bar'}

  describe 'plain response', ->
    app = new UnicoApp()
    resp = undefined

    beforeEach (done) ->
      app.addModel 'foo', '/api/foo', format: 'plain'
      jasmine.Ajax.install();
      jasmine.Ajax.stubRequest('/api/foo').andReturn responseText: 'foo bar'
      model = app.model 'foo'
      model.index().then (data) ->
        resp = data
        done()

    it 'should return the plain response', ->
      expect(resp).toEqual 'foo bar'

  describe 'invalid json', ->
    app = new UnicoApp()
    resp = undefined

    beforeEach (done) ->
      app.addModel 'foo', '/api/foo'
      jasmine.Ajax.install();
      jasmine.Ajax.stubRequest('/api/foo').andReturn responseText: 'foo bar'
      model = app.model 'foo'
      model.index().then (data) ->
        resp = data
        done()

    it 'should return the plain response', ->
      expect(resp).toEqual 'foo bar'

  # Build params
  #----------------------------------------------------------------------

  describe 'build params', ->
    describe 'build params in url', ->
      app = new UnicoApp()
      resp = undefined

      beforeEach (done) ->
        app.addModel 'foo', '/api/foo/:id', format: 'plain'
        jasmine.Ajax.install();
        jasmine.Ajax.stubRequest('/api/foo/1').andReturn responseText: 'foo bar'
        model = app.model 'foo'
        model.get(id: 1).then (data) ->
          resp = data
          done()

      it 'build the params', ->
        expect(resp).toEqual 'foo bar'

    describe 'empty params', ->
      app = new UnicoApp()
      resp = undefined

      beforeEach (done) ->
        app.addModel 'foo', '/api/foo/:id', format: 'plain'
        jasmine.Ajax.install();
        jasmine.Ajax.stubRequest('/api/foo').andReturn responseText: 'foo bar'
        model = app.model 'foo'
        model.get().then (data) ->
          resp = data
          done()

      it 'should ignore params', ->
        expect(resp).toEqual 'foo bar'

    describe 'url parameters', ->
      app = new UnicoApp()
      resp = undefined

      beforeEach (done) ->
        app.addModel 'foo', '/api/foo', format: 'plain'
        jasmine.Ajax.install();
        jasmine.Ajax.stubRequest('/api/foo?foo=bar').andReturn responseText: 'foo bar'
        model = app.model 'foo'
        model.get({}, foo: 'bar').then (data) ->
          resp = data
          done()

      it 'build the params', ->
        expect(resp).toEqual 'foo bar'
