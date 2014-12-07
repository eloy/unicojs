describe 'MetaElement', ->
  ctx = new UnicoContext new UnicoApp(), {}

  describe '_extractMeta', ->
    it 'should generate a node from the given html element', ->
      html = '''<div id="root">foo</div>'''
      addFixture html
      el = new MetaElement ctx, getFixtureElement()
      expect(el.tag).toBe 'div'
      expect(el.attrs.id).toBe 'root'
      expect(el.nodes.length).toBe 1
      expect(el.nodes[0].data).toBe 'foo'
      expect(el.nodes[0].text).toBeTruethly


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
    it 'should read attributes from element and return a hash', ->
      html = '''<div id="foo" if="view() > 0" data-bar="wadus" directive>blah blah</div>'''
      addFixture html
      el = new MetaElement ctx, getFixtureElement()
      expect(el.attrs).toEqual {id: 'foo', if: 'view() > 0', "data-bar": 'wadus', directive: ''}

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


  # _attrachDirectives
  #----------------------------------------------------------------------

  describe "_attachDirectives", ->
    it 'should add directives', ->
      app = new UnicoApp()
      ctx = new UnicoContext app, {}
      foo = {}
      app.addDirective 'foo', foo
      meta = createMeta ctx, '''<div foo="bar">Wadus</div>'''
      expect(meta.directives).toEqual [{func: foo}]

  # _denormalizeRepeat
  #----------------------------------------------------------------------

  describe '_denormalizeRepeat', ->
    it 'should not set as repeat if expression does not match', ->
      meta = createMeta ctx, '''<div repeat="items()">Wadus</div>'''
      expect(meta.repeat).toBeFalse


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
