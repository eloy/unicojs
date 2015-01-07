describe 'Route', ->
  describe 'route', ->
    it 'should add a route', ->
      r = new Route(false, '/')
      r.route '/site', controller: 'site_controller', layout: '/site.html'
      expect(r._routes.length).toBe 1
      expect(r._routes[0].path).toEqual '/site'
      expect(r._routes[0].controller).toEqual 'site_controller'
      expect(r._routes[0].layout).toEqual '/site.html'


    it 'should add childrens', ->
      r = new Route(false, '/')
      r.route '/users', controller: 'users_controller', layout: '/users.html', (r) ->
        r.route('/:id', controller: 'show_controller', layout: '/show.html')
        r.route('/new', controller: 'new_controller', layout: '/new.html')

      root = r._routes[0]
      expect(r._routes.length).toBe 1

      expect(root.path).toEqual '/users'
      expect(root.controller).toEqual 'users_controller'
      expect(root.layout).toEqual '/users.html'

      expect(root._routes.length).toBe 2

      first = root._routes[0]
      expect(first.path).toEqual '/users/:id'
      expect(first.controller).toEqual 'show_controller'
      expect(first.layout).toEqual '/show.html'

      last = root._routes[1]
      expect(last.path).toEqual '/users/new'
      expect(last.controller).toEqual 'new_controller'
      expect(last.layout).toEqual '/new.html'
