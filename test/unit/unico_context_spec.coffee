describe "UnicoContext", ->
  app = new UnicoApp()

  # eval
  #----------------------------------------------------------------------

  describe 'eval', ->
    it 'should return null if error', ->
      ctx = new UnicoContext app, {}
      expect(ctx.eval("test()")).toBeUndefined

    describe 'functions', ->
      it 'should eval the given function', ->
        ctrl = {test: -> 'foo'}
        ctx = new UnicoContext app, ctrl
        expect(ctx.eval("test()")).toEqual 'foo'

      it 'should run functions inside the controller scope', ->
        ctrl = {prop: 'foo', test: (-> @prop) }
        ctx = new UnicoContext app, ctrl
        expect(ctx.eval("test()")).toEqual 'foo'


    describe 'properties', ->
      it 'should return the value of the given property', ->
        ctrl = {test: 'foo'}
        ctx = new UnicoContext app, ctrl
        expect(ctx.eval("test")).toEqual 'foo'

  # interpolate
  #----------------------------------------------------------------------
  describe 'interpolate', ->
    it 'should replace expressions in string', ->
      ctrl = {foo: 'F00', bar: (-> 'B44R')}
      ctx = new UnicoContext app, ctrl
      expect(ctx.interpolate("I saw {{foo}} in the {{bar()}}")).toEqual 'I saw F00 in the B44R'


  # child
  #----------------------------------------------------------------------

  describe 'child', ->
    it 'should create a new child context with the given scope', ->
      ctrl = {foo: 'HEY'}
      ctx = new UnicoContext app, ctrl
      child = ctx.child bar: 'HO'
      expect(child.eval('foo')).toEqual 'HEY'
      expect(child.eval('bar')).toEqual 'HO'

    it 'should respect nested scopes', ->
      ctrl = {foo: 'HEY'}
      ctx = new UnicoContext app, ctrl
      child = ctx.child bar: 'HO'
      subChild = child.child wadus: 'LETS GO'
      expect(subChild.eval('foo')).toEqual 'HEY'
      expect(subChild.eval('bar')).toEqual 'HO'
      expect(subChild.eval('wadus')).toEqual 'LETS GO'


    it 'should silently override params of parent scopes', ->
      ctrl = {foo: 'HEY'}
      ctx = new UnicoContext app, ctrl
      child = ctx.child bar: 'HO'
      subChild = child.child foo: 'LETS GO'
      expect(subChild.eval('foo')).toEqual 'LETS GO'
      expect(subChild.eval('bar')).toEqual 'HO'
