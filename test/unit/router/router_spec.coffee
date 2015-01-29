describe 'Router', ->
  describe 'route', ->
    it 'should add a route', ->
      r = new UnicoRouter()
      r.route '/site', controller: 'site_controller', partial: '/site.html'
      expect(r.root._routes.length).toBe 1
      expect(r.root._routes[0].path).toEqual '/site'
      expect(r.root._routes[0].controller).toEqual 'site_controller'
      expect(r.root._routes[0].partial).toEqual '/site.html'


  describe 'find', ->
    describe 'root', ->
      it 'should return the root route', ->
        router = new UnicoRouter()
        expect(router.find("/").route).toBe router.root

    describe 'simple route', ->
      it 'should return the route', ->
        router = new UnicoRouter()
        r = router.route '/site'
        expect(router.find("/site").route).toBe r

    describe 'route with params', ->
      it 'should return the route', ->
        router = new UnicoRouter()
        foo = router.route '/foo/:id'
        bar = router.route '/bar/:id'
        resp = router.find("/foo/1")
        expect(resp.route).toBe foo
        expect(resp.params).toEqual {id: '1'}


    describe 'neested routes', ->
      it 'should return the route', ->
        router = new UnicoRouter()
        foo = router.route '/foo/:foo_id'
        bar = foo.route '/bar/:id'
        resp = router.find("/foo/1/bar/2")
        expect(resp.route).toBe bar
        expect(resp.params).toEqual {foo_id: '1', id: '2'}
