describe 'Route', ->
  describe 'route', ->
    it 'should add a route', ->
      r = new Route(false, '/')
      r.route '/site', controller: 'site_controller', layout: '/site.html'
      expect(r._routes.length).toBe 1
      expect(r._routes[0].path).toEqual '/site'
      expect(r._routes[0].controller).toEqual 'site_controller'
      expect(r._routes[0].layout).toEqual '/site.html'
