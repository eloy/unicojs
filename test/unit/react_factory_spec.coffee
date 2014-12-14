describe 'ReactFactory', ->
  app = new UnicoApp()
  instance = {app: app}

  # buildElement
  #----------------------------------------------------------------------

  describe 'buildElement', ->
    it 'should return null if meta.attrs.hide is true', ->
      ctrl = {info: 'foo'}
      ctx = new UnicoContext instance, ctrl
      meta = createMeta ctx, "<button>foo</button>"
      meta.attrs.hide = true
      expect(ReactFactory.buildElement meta, ctx).toBe null

    # HTML Standard element
    #----------------------------------------------------------------------

    describe 'html element', ->
      it 'should return a React element', ->
        ctrl = {info: 'foo'}
        ctx = new UnicoContext instance, ctrl
        meta = createMeta ctx, "<button>foo</button>"
        el = ReactFactory.buildElement meta, ctx
        react = React.renderToString(el)
        expect($(react).text()).toEqual 'foo'
        expect(react).toMatch '</button>'

    # Directives
    #----------------------------------------------------------------------

    describe 'element with directives', ->
      it 'should return the ReactClass', ->
        app = new UnicoApp()
        instance = {app: app}
        ctx = new UnicoContext instance, {}
        class TestDirective
        app.addDirective 'foo', TestDirective
        meta = createMeta ctx, '''<div foo="bar">Wadus</div>'''
        el = ReactFactory.buildElement meta, ctx
        react = React.renderToString(el)
        expect($(react).text()).toEqual 'Wadus'


      it 'should duplicate meta and remove reactClass from them', ->
        app = new UnicoApp()
        instance = {app: app}
        ctx = new UnicoContext instance, {}
        class TestDirective
        app.addDirective 'foo', TestDirective
        meta = createMeta ctx, '''<div foo="bar">Wadus</div>'''
        el = ReactFactory.buildElement meta, ctx
        expect(el.props.meta.reactClass).toBe false
        expect(meta.reactClass).not.toBeDefined


    # Text Element
    #----------------------------------------------------------------------

    describe 'text element not interpolated', ->
      it 'should return a React element', ->
        ctrl = {info: 'foo'}
        ctx = new UnicoContext ctrl
        meta = createMeta ctx, "Foo"
        el = ReactFactory.buildElement meta, ctx
        expect(el).toEqual 'Foo'

    describe 'text element interpolated', ->
      it 'should return a React element', ->
        ctrl = {info: 'foo'}
        ctx = new UnicoContext app, ctrl
        meta = createMeta ctx, "Var is {{info}} end"
        el = ReactFactory.buildElement meta, ctx
        expect(el).toEqual ['Var is ', 'foo', ' end']

    # Templates
    #----------------------------------------------------------------------

    describe 'templates', ->
      it 'should render the template inside the placeholder', ->
        tmpl_html = '''<script type="text/html" id="template_1">foo</script>'''
        view_html = '''<div><span template="template_1"></span> bar</div>'''
        app = new UnicoApp()
        instance = {app: app}
        ctx = new UnicoContext instance, {}
        tmpl_meta = createMeta ctx, tmpl_html
        view_meta = createMeta ctx, view_html
        el = ReactFactory.buildElement view_meta, ctx
        react = React.renderToString(el)
        expect($(react).text()).toEqual 'foo bar'

      it 'should accept templates defined inside the html', ->
        html = '''<div><div><span template="template_1"></span> bar</div><script type="text/html" id="template_1">foo</script><div>'''
        app = new UnicoApp()
        instance = {app: app}
        ctx = new UnicoContext instance, {}
        meta = createMeta ctx, html
        el = ReactFactory.buildElement meta, ctx
        react = React.renderToString(el)
        expect($(react).text()).toEqual 'foo bar'

  # _buildRepeat
  #----------------------------------------------------------------------

  describe '_buildRepeat', ->
    describe 'with collections', ->
      it 'should return an array of elements', ->
        html = '''
          <div repeat="item in data">
            <div class="item">
              Item is: {{item}}
            </div>
          </div>
        '''
        ctrl = {data: ['foo', 'bar']}
        ctx = new UnicoContext instance, ctrl
        meta = createMeta ctx, html
        el = ReactFactory.buildElement meta, ctx
        react = React.renderToString(el)
        expect($(react).text()).toMatch 'Item is: foo'
        expect($(react).text()).toMatch 'Item is: bar'
