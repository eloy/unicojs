describe 'MetaElement', ->
  app = new UnicoApp()
  instance = {app: app}
  ctx = new UnicoContext instance, {}

  describe '_extractMeta', ->
    it 'should generate a node from the given html element', ->
      html = '''<div id="root">foo</div>'''
      addFixture html
      el = new MetaElement ctx, getFixtureElement()
      expect(el.tag).toBe 'div'
      expect(el.attrs.id).toBe 'root'
      expect(el.nodes.length).toBe 1
      expect(el.nodes[0].data).toBe 'foo'
      expect(el.nodes[0].text).toBeTruthy()

    it 'should register the element if it is a template', ->
      html = '''<script type="text/html" id="template_1">foo</script>'''
      addFixture html
      el = new MetaElement ctx, getFixtureElement()
      expect(el.tag).toBe 'script'
      expect(instance.templates['template_1']).toBeDefined()

  # extractChildrens
  #----------------------------------------------------------------------

  describe '_extractChildrens', ->
    it 'should return an array of metaNodes', ->
      html = '''
        <div id="root">ping<br/>pong</div>'''
      addFixture html
      el = new MetaElement ctx, getFixtureElement()
      expect(el.nodes.length).toBe 3
      expect(el.nodes[0].tag).toBe undefined
      expect(el.nodes[0].data).toBe 'ping'
      expect(el.nodes[1].tag).toBe 'br'
      expect(el.nodes[2].data).toBe 'pong'

  # _extractAttributes
  #----------------------------------------------------------------------

  describe '_extractAttributes', ->
    it 'should read attributes from element and store it in @attrs', ->
      html = '''<div id="foo" if="view() > 0" data-bar="wadus" directive>blah blah</div>'''
      addFixture html
      el = new MetaElement ctx, getFixtureElement()
      expect(el.attrs).toEqual {id: 'foo', if: 'view() > 0', "data-bar": 'wadus', directive: ''}
      expect(el.attrsInterpolated).toBeUndefined()

    it 'should read attributes with variables from element and store them in @attrsInterpolated', ->
      html = '''<div id="{{foo}}">blah blah</div>'''
      addFixture html
      el = new MetaElement ctx, getFixtureElement()
      expect(el.attrs).toEqual id: "{{foo}}"
      expect(el.attrsInterpolated).toEqual id: "{{foo}}"

    it 'should replace class with className', ->
      html = '''<div class="foo">blah blah</div>'''
      addFixture html
      el = new MetaElement ctx, getFixtureElement()
      expect(el.attrs).toEqual {className: 'foo'}

  # _splitInterpolated
  #----------------------------------------------------------------------

  describe "_splitInterpolated", ->
    it 'should return an array of strings and elements', ->
      el = new MetaElement ctx, {}
      html = "ola {{foo}} ase {{foo}}{{bar}} end"
      expect(el._splitInterpolated(html)).toEqual [
        {t: "text", v: "ola "},
        {t: "exp", v: "foo"},
        {t: "text", v: " ase "},
        {t: "exp", v: "foo"},
        {t: "exp", v: "bar"},
        {t: "text", v: " end"}
      ]

    it 'should support ||', ->
      el = new MetaElement ctx, {}
      html = "var is {{foo || bar}}"
      expect(el._splitInterpolated(html)).toEqual [
        {t: "text", v: "var is "},
        {t: "exp", v: "foo || bar"},
      ]



  # _denormalizeRepeat
  #----------------------------------------------------------------------

  describe '_denormalizeRepeat', ->
    it 'should not set as repeat if expression does not match', ->
      meta = createMeta ctx, '''<div repeat="items()">Wadus</div>'''
      expect(meta.repeat).toBeFalsy()


    describe 'as a collection', ->
      it 'should extract variables and expression from repeat property', ->
        meta = createMeta ctx, '''<div repeat="item in items">Wadus</div>'''
        expect(meta.repeatExp).toEqual {value: 'item', src: 'items'}

      it 'should extract variables and expression from repeat function', ->
        meta = createMeta ctx, '''<div repeat="item in items()">Wadus</div>'''
        expect(meta.repeatExp).toEqual {value: 'item', src: 'items()'}

    describe 'as a hash', ->
      it 'should extract variables and expression from repeat property', ->
        meta = createMeta ctx, '''<div repeat="item, name in items">Wadus</div>'''
        expect(meta.repeatExp).toEqual {key: 'item', value: 'name' , src: 'items'}

      it 'should extract variables and expression from repeat function', ->
        meta = createMeta ctx, '''<div repeat="item, name in items()">Wadus</div>'''
        expect(meta.repeatExp).toEqual {key: 'item', value: 'name' , src: 'items()'}


  # _denormalizeOptions
  #----------------------------------------------------------------------

  describe '_denormalizeOptions', ->
    it 'should not set as options if expression does not match', ->
      meta = createMeta ctx, '''<div options="items()">Wadus</div>'''
      expect(meta.options).toBeFalsy()


    describe 'as a collection', ->
      it 'should extract variables and expression from options property', ->
        meta = createMeta ctx, '''<div options="item from item in items">Wadus</div>'''
        expect(meta.optionsExp.from).toEqual {value: 'item', src: 'items'}
        expect(meta.optionsExp.field).toEqual {value: 'item', src: 'item'}

      it 'should extract variables and expression from options function', ->
        meta = createMeta ctx, '''<div options="item from item in items()">Wadus</div>'''
        expect(meta.optionsExp.from).toEqual {value: 'item', src: 'items()'}
        expect(meta.optionsExp.field).toEqual {value: 'item', src: 'item'}

    describe 'as a hash', ->
      it 'should extract variables and expression from options property', ->
        meta = createMeta ctx, '''<div options="item as name from item, name in items">Wadus</div>'''
        expect(meta.optionsExp.from).toEqual {key: 'item', value: 'name' , src: 'items'}
        expect(meta.optionsExp.field).toEqual {key: "item", value: 'name', src: 'item as name'}

      it 'should extract variables and expression from options function', ->
        meta = createMeta ctx, '''<div options="name.id as name.label from item, name in items()">Wadus</div>'''
        expect(meta.optionsExp.from).toEqual {key: 'item', value: 'name' , src: 'items()'}
        expect(meta.optionsExp.field).toEqual {key: "name.id", value: 'name.label', src: 'name.id as name.label'}


  # _attachDirectives
  #----------------------------------------------------------------------

  describe "_attachDirectives", ->
    it 'should add directives', ->
      app = new UnicoApp()
      instance = {app: app}
      ctx = new UnicoContext instance, {}
      foo = {}
      app.addDirective 'foo', foo
      meta = createMeta ctx, '''<div foo="bar">Wadus</div>'''
      expect(meta.directives).toEqual [{clazz: foo}]

    it 'should create a reactClass', ->
      app = new UnicoApp()
      instance = {app: app}
      ctx = new UnicoContext instance, {}
      foo = {}
      app.addDirective 'foo', foo
      meta = createMeta ctx, '''<div foo="bar">Wadus</div>'''
      expect(meta.reactClass).toBeDefined()


  describe 'attachComponent from tag', ->
    it 'should extract build this.component', ->
      class TestComponent
        @template: '<div id="foo">FOO</div>'
      html = '<test id="bar"></test>'
      ctx = createCtx()
      app = ctx.app
      app.addComponent 'test', TestComponent
      meta = createMeta ctx, html
      expect(meta.component).toBeDefined()
      expect(meta.reactClass).toBeDefined()

  describe 'attachComponent from property', ->
    it 'should extract build this.component', ->
      class TestComponent
        @template: '<div id="foo">FOO</div>'
      html = '<div component="test" id="bar"></div>'
      ctx = createCtx()
      app = ctx.app
      app.addComponent 'test', TestComponent
      meta = createMeta ctx, html
      expect(meta.component).toBeDefined()
      expect(meta.reactClass).toBeDefined()


  # prepareIgnition
  #----------------------------------------------------------------------

  describe "prepareIgnition", ->
    it 'should instantiate directives', ->
      app = new UnicoApp()
      instance = {app: app}
      ctx = new UnicoContext instance, {}
      class MyDirective
        constructor: ->
          @built = false
        build: ->
          @built = true

      app.addDirective 'foo', MyDirective
      meta = createMeta ctx, '''<div foo="bar">Wadus</div>'''
      meta.prepareIgnition(ctx)
      directive = meta.directives[0].instance
      expect(directive.built).toBeTruthy()


    it 'should fill interpolated attributes', ->
      class Test
        foo: "BAR"

      app = new UnicoApp()
      app.addController 'test', Test
      instance = {app: app}
      ctx = new UnicoContext instance, 'test'
      meta = createMeta ctx, '''<div foo="{{foo}}" bar="{{bar}}">Wadus</div>'''
      meta.prepareIgnition(ctx)
      expect(meta.attrs.foo).toBe 'BAR'
      expect(meta.attrs.bar).toBe ''
