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
      app.router.rootOptions layout: '/home/foo', controller: 'test_controller'
      app.router.route '/bar', layout: '/home/bar', controller: 'test_controller'
      app.startRouter()

    it 'should render differente layouts based on the path', (done) ->
      expect($("#reactTarget").text()).toEqual 'Content is: FOO'
      callback = done
      app.visit '/bar'

    afterEach ->
      expect($("#reactTarget").text()).toEqual 'Content is: BAR'
