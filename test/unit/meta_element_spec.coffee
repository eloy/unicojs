describe 'MetaElement', ->
  describe '_extractMeta', ->
    it 'should generate a node from the given html element', ->
      html = '''<div id="root">foo</div>'''
      addFixture html
      el = new MetaElement getFixtureElement()
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
      el = new MetaElement getFixtureElement()
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
      el = new MetaElement getFixtureElement()
      expect(el.attrs).toEqual {id: 'foo', if: 'view() > 0', "data-bar": 'wadus', directive: ''}

    it 'should replace class with className', ->
      html = '''<div class="foo">blah blah</div>'''
      addFixture html
      el = new MetaElement getFixtureElement()
      expect(el.attrs).toEqual {className: 'foo'}


  describe "_splitInterpolated", ->
    it 'should return an array of strings and elements', ->
      el = new MetaElement {}
      html = "ola {{foo}} ase {{foo}}{{bar}} end"
      expect(el._splitInterpolated(html)).toEqual [
        {t: "text", v: "ola "},
        {t: "exp", v: "foo"},
        {t: "text", v: " ase "},
        {t: "exp", v: "foo"},
        {t: "exp", v: "bar"},
        {t: "text", v: " end"}
      ]
