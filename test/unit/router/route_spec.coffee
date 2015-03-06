describe 'Route', ->
  describe 'route', ->
    it 'should add a route', ->
      r = new Route(false, '/')
      r.route '/site', controller: 'site_controller', partial: '/site.html'
      expect(r._routes.length).toBe 1
      expect(r._routes[0].path).toEqual '/site'
      expect(r._routes[0].controller).toEqual 'site_controller'
      expect(r._routes[0].partial).toEqual '/site.html'


    it 'should add childrens', ->
      r = new Route(false, '/')
      r.route '/users', controller: 'users_controller', partial: '/users.html', (r) ->
        r.route('/:id', controller: 'show_controller', partial: '/show.html')
        r.route('/new', controller: 'new_controller', partial: '/new.html')

      root = r._routes[0]
      expect(r._routes.length).toBe 1

      expect(root.path).toEqual '/users'
      expect(root.controller).toEqual 'users_controller'
      expect(root.partial).toEqual '/users.html'

      expect(root._routes.length).toBe 2

      first = root._routes[0]
      expect(first.path).toEqual '/users/:id'
      expect(first.controller).toEqual 'show_controller'
      expect(first.partial).toEqual '/show.html'

      last = root._routes[1]
      expect(last.path).toEqual '/users/new'
      expect(last.controller).toEqual 'new_controller'
      expect(last.partial).toEqual '/new.html'

  describe 'resorces', ->
    it 'should add resources', ->
      root = new Route(false, '/')
      root.resources 'users'

      r = root.find('/users').route
      expect(r.path).toEqual '/users'
      expect(r.controller).toEqual 'users#index'
      expect(r.partial).toEqual '/users/index.html'

      r = root.find('/users/new').route
      expect(r.path).toEqual '/users/new'
      expect(r.controller).toEqual 'users#new'
      expect(r.partial).toEqual '/users/new.html'

      r = root.find('/users/1').route
      expect(r.path).toEqual '/users/:id'
      expect(r.controller).toEqual 'users#show'
      expect(r.partial).toEqual '/users/show.html'


      r = root.find('/users/1/edit').route
      expect(r.path).toEqual '/users/:id/edit'
      expect(r.controller).toEqual 'users#edit'
      expect(r.partial).toEqual '/users/edit.html'

    describe 'parameter namespace', ->
      it 'should add the namespace to the route and his childrens', ->

        root = new Route(false, '/')
        root.route '/admin', namespace: 'admin', controller: 'admin_controller#index', partial: '/admin/index', (admin) ->
          admin.resources 'users', {}, (member, collection) ->
            member.resources 'posts'

        # Admin routes
        r = root._routes[0]._routes
        r = root.find('/admin/users').route
        expect(r.path).toEqual '/admin/users'
        expect(r.controller).toEqual 'admin_users#index'
        expect(r.partial).toEqual '/admin/users/index.html'

        r = root.find('/admin/users/new').route
        expect(r.path).toEqual '/admin/users/new'
        expect(r.controller).toEqual 'admin_users#new'
        expect(r.partial).toEqual '/admin/users/new.html'

        r = root.find('/admin/users/1').route
        expect(r.path).toEqual '/admin/users/:id'
        expect(r.controller).toEqual 'admin_users#show'
        expect(r.partial).toEqual '/admin/users/show.html'

        r = root.find('/admin/users/1/edit').route
        expect(r.path).toEqual '/admin/users/:id/edit'
        expect(r.controller).toEqual 'admin_users#edit'
        expect(r.partial).toEqual '/admin/users/edit.html'


        r = root.find('/admin/users/1/posts/2/edit').route
        expect(r.path).toEqual '/admin/users/:user_id/posts/:id/edit'
        expect(r.controller).toEqual 'admin_posts#edit'
        expect(r.partial).toEqual '/admin/posts/edit.html'
