describe 'ReactFactory', ->
  app = new UnicoApp()
  instance = {app: app}

  # buildElement
  #----------------------------------------------------------------------

  describe 'buildElement', ->
    describe 'html element', ->
      it 'should return a React element', ->
        ctrl = {info: 'foo'}
        ctx = new UnicoContext ctrl
        meta = createMeta ctx, "<button>foo</button>"
        el = ReactFactory.buildElement meta, ctx
        # TODO: How to test this?

    describe 'element with directives', ->
      it 'should return the ReactClass', ->
        app = new UnicoApp()
        instance = {app: app}
        ctx = new UnicoContext instance, {}
        foo = {}
        app.addDirective 'foo', foo
        meta = createMeta ctx, '''<div foo="bar">Wadus</div>'''
        el = ReactFactory.buildElement meta, ctx
        expect(el.props.ctx).toEqual ctx
        expect(el.props.meta.reactClass).toBeFalse

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
        # TODO: how to test this?
