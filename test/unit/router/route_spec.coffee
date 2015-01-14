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

  describe 'resorces', ->
    it 'should add resources', ->
      root = new Route(false, '/')
      root.resources 'users'

      r = root.find('/users').route
      expect(r.path).toEqual '/users'
      expect(r.controller).toEqual 'users#index'
      expect(r.layout).toEqual '/users/index'

      r = root.find('/users/new').route
      expect(r.path).toEqual '/users/new'
      expect(r.controller).toEqual 'users#new'
      expect(r.layout).toEqual '/users/new'

      r = root.find('/users/1').route
      expect(r.path).toEqual '/users/:id'
      expect(r.controller).toEqual 'users#show'
      expect(r.layout).toEqual '/users/show'


      r = root.find('/users/1/edit').route
      expect(r.path).toEqual '/users/:id/edit'
      expect(r.controller).toEqual 'users#edit'
      expect(r.layout).toEqual '/users/edit'

    describe 'parameter namespace', ->
      it 'should add the namespace to the route and his childrens', ->

        root = new Route(false, '/')
        root.route '/admin', namespace: 'admin', controller: 'admin_controller#index', layout: '/admin/index', (admin) ->
          admin.resources 'users', {}, (member, collection) ->
            member.resources 'posts'

        # Admin routes
        r = root._routes[0]._routes
        r = root.find('/admin/users').route
        expect(r.path).toEqual '/admin/users'
        expect(r.controller).toEqual 'admin_users#index'
        expect(r.layout).toEqual '/admin/users/index'

        r = root.find('/admin/users/new').route
        expect(r.path).toEqual '/admin/users/new'
        expect(r.controller).toEqual 'admin_users#new'
        expect(r.layout).toEqual '/admin/users/new'

        r = root.find('/admin/users/1').route
        expect(r.path).toEqual '/admin/users/:id'
        expect(r.controller).toEqual 'admin_users#show'
        expect(r.layout).toEqual '/admin/users/show'

        r = root.find('/admin/users/1/edit').route
        expect(r.path).toEqual '/admin/users/:id/edit'
        expect(r.controller).toEqual 'admin_users#edit'
        expect(r.layout).toEqual '/admin/users/edit'


        r = root.find('/admin/users/1/posts/2/edit').route
        expect(r.path).toEqual '/admin/users/:user_id/posts/:id/edit'
        expect(r.controller).toEqual 'admin_posts#edit'
        expect(r.layout).toEqual '/admin/posts/edit'
