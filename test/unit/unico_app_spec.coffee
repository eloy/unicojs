describe 'UnicoApp', ->
  describe 'render', ->
    it 'should create instances for each controller in the given dom', ->
      addFixture '''
      <div id="test" controller="test">
        {{fieldFoo}}
      </div>
      '''
      class TestController
        fieldFoo: 'FOO'

      app = new UnicoApp()
      app.addController 'test', TestController
      app.render()
      expect(app.instances.length).toBe 1
      el = $("#test")
      expect(el.text().trim()).toEqual 'FOO'

  describe 'startRouter', ->
    describe 'hash router', ->
      layoutHtml = '<div id="layout">Content is: <div content="main"></div></div>'
      fooHtml = '<div id="fooContent">{{foo}}</div>'
      barHtml = '<div id="barContent">{{bar}}</div>'
      callback = undefined
      app = new UnicoApp(enableRouter: true, targetElement: '#reactTarget')

      class TestController
        foo: 'FOO'
        bar: 'BAR'

      beforeEach (done) ->
        jasmine.Ajax.install();
        jasmine.Ajax.stubRequest('/layouts/application.html').andReturn responseText: layoutHtml, status: 200
        jasmine.Ajax.stubRequest('/home/foo').andReturn responseText: fooHtml, status: 200
        jasmine.Ajax.stubRequest('/home/bar').andReturn responseText: barHtml, status: 200

        addFixture '<div id="reactTarget"></div>'
        callback = done
        app.addMountListener (() -> callback())
        app.addController 'test_controller', TestController
        app.router.rootOptions partial: '/home/foo', controller: 'test_controller'
        app.router.route '/bar', partial: '/home/bar', controller: 'test_controller'
        app.startRouter()

      it 'should render differente partialss based on the path', (done) ->
        expect(app.router.driver.constructor.name).toEqual 'HashDriver'
        expect($("#reactTarget").text()).toEqual 'Content is: FOO'
        callback = done
        app.visit '/bar'

      afterEach ->
        expect($("#reactTarget").text()).toEqual 'Content is: BAR'

    describe 'history router', ->
      layoutHtml = '<div id="layout">Content is: <div content="main"></div></div>'
      fooHtml = '<div id="fooContent">{{foo}}</div>'
      barHtml = '<div id="barContent">{{bar}}</div>'
      callback = undefined
      app = new UnicoApp(enableRouter: true, routerType: 'history', targetElement: '#reactTarget')

      class TestController
        foo: 'FOO'
        bar: 'BAR'

      beforeEach (done) ->
        jasmine.Ajax.install();
        jasmine.Ajax.stubRequest('/layouts/application.html').andReturn responseText: layoutHtml, status: 200
        jasmine.Ajax.stubRequest('/home/foo').andReturn responseText: fooHtml, status: 200
        jasmine.Ajax.stubRequest('/home/bar').andReturn responseText: barHtml, status: 200

        addFixture '<div id="reactTarget"></div>'
        callback = done
        app.addMountListener (() -> callback())
        app.addController 'test_controller', TestController
        app.router.rootOptions partial: '/home/foo', controller: 'test_controller'
        app.router.route '/bar', partial: '/home/bar', controller: 'test_controller'
        app.startRouter()

      it 'should render differente partials based on the path', (done) ->
        expect(app.router.driver.constructor.name).toEqual 'HistoryDriver'
        expect($("#reactTarget").text()).toEqual 'Content is: FOO'
        callback = done
        app.visit '/bar'

      afterEach ->
        expect($("#reactTarget").text()).toEqual 'Content is: BAR'

  describe 'custom', ->
    layoutHtml = '<div id="layout">Content is: <div content="main"></div></div>'
    fooHtml = '<div id="fooContent">{{foo}}</div>'
    barHtml = '<div id="barContent">{{bar}}</div>'
    callback = undefined
    app = new UnicoApp(enableRouter: true, routerType: 'history', targetElement: '#reactTarget')

    class TestController
      layout: 'custom'
      foo: 'FOO'
      bar: 'BAR'

    beforeEach (done) ->
      jasmine.Ajax.install();
      jasmine.Ajax.stubRequest('/layouts/custom.html').andReturn responseText: layoutHtml, status: 200
      jasmine.Ajax.stubRequest('/home/foo').andReturn responseText: fooHtml, status: 200
      jasmine.Ajax.stubRequest('/home/bar').andReturn responseText: barHtml, status: 200

      addFixture '<div id="reactTarget"></div>'
      callback = done
      app.addMountListener (() -> callback())
      app.addController 'test_controller', TestController
      app.router.rootOptions partial: '/home/foo', controller: 'test_controller'
      app.router.route '/bar', partial: '/home/bar', controller: 'test_controller'
      app.visit("/")
      app.startRouter()

    it 'should render differente partials based on the path', (done) ->
      expect(app.router.driver.constructor.name).toEqual 'HistoryDriver'
      expect($("#reactTarget").text()).toEqual 'Content is: FOO'
      callback = done
      app.visit '/bar'

    afterEach ->
      expect($("#reactTarget").text()).toEqual 'Content is: BAR'
