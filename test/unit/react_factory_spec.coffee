describe 'ReactFactory', ->
  describe 'buildElement', ->
    describe 'html element', ->
      it 'should return a React element', ->
        ctrl = {info: 'foo'}
        ctx = new UnicoContext ctrl
        meta = createMeta ctx, "<button>foo</button>"
        el = ReactFactory.buildElement meta, ctx
        # TODO: How to test this?

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
        ctx = new UnicoContext {}, ctrl
        meta = createMeta ctx, "Var is {{info}} end"
        el = ReactFactory.buildElement meta, ctx
        expect(el).toEqual ['Var is ', 'foo', ' end']
