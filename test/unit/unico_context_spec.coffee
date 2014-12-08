describe "UnicoContext", ->
  app = new UnicoApp()
  instance = {app: app}

  # eval
  #----------------------------------------------------------------------

  describe 'eval', ->
    it 'should return null if error', ->
      ctx = new UnicoContext instance, {}
      expect(ctx.eval("test()")).toBeUndefined

    describe 'functions', ->
      it 'should eval the given function', ->
        ctrl = {test: -> 'foo'}
        ctx = new UnicoContext instance, ctrl
        expect(ctx.eval("test()")).toEqual 'foo'

      it 'should run functions inside the controller scope', ->
        ctrl = {prop: 'foo', test: (-> @prop) }
        ctx = new UnicoContext instance, ctrl
        expect(ctx.eval("test()")).toEqual 'foo'


    describe 'properties', ->
      it 'should return the value of the given property', ->
        ctrl = {test: 'foo'}
        ctx = new UnicoContext instance, ctrl
        expect(ctx.eval("test")).toEqual 'foo'

  # interpolate
  #----------------------------------------------------------------------
  describe 'interpolate', ->
    it 'should replace expressions in string', ->
      ctrl = {foo: 'F00', bar: (-> 'B44R')}
      ctx = new UnicoContext instance, ctrl
      expect(ctx.interpolate("I saw {{foo}} in the {{bar()}}")).toEqual 'I saw F00 in the B44R'


  # child
  #----------------------------------------------------------------------

  describe 'child', ->
    it 'should create a new child context with the given scope', ->
      ctrl = {foo: 'HEY'}
      ctx = new UnicoContext instance, ctrl
      child = ctx.child bar: 'HO'
      expect(child.eval('foo')).toEqual 'HEY'
      expect(child.eval('bar')).toEqual 'HO'

    it 'should respect nested scopes', ->
      ctrl = {foo: 'HEY'}
      ctx = new UnicoContext instance, ctrl
      child = ctx.child bar: 'HO'
      subChild = child.child wadus: 'LETS GO'
      expect(subChild.eval('foo')).toEqual 'HEY'
      expect(subChild.eval('bar')).toEqual 'HO'
      expect(subChild.eval('wadus')).toEqual 'LETS GO'


    it 'should silently override params of parent scopes', ->
      ctrl = {foo: 'HEY'}
      ctx = new UnicoContext instance, ctrl
      child = ctx.child bar: 'HO'
      subChild = child.child foo: 'LETS GO'
      expect(subChild.eval('foo')).toEqual 'LETS GO'
      expect(subChild.eval('bar')).toEqual 'HO'


  describe 'evalAndWatch', ->
    it 'should cache expression', ->
      ctrl = {count: 0, val: (-> ++@count)}
      ctx = new UnicoContext instance, ctrl
      expect(ctx.evalAndWatch("val()")).toBe 1
      expect(ctx.evalAndWatch("val()")).toBe 1
      expect(ctrl.count).toBe 1

  describe '_cleanWatched', ->
    it 'should clean cache expression', ->
      ctrl = {count: 0, val: (-> ++@count)}
      ctx = new UnicoContext instance, ctrl
      expect(ctx.evalAndWatch("val()")).toBe 1
      ctx.changed()
      expect(ctx.evalAndWatch("val()")).toBe 2


  describe 'changed', ->
    it 'should emit a change event', ->
      ctrl = {foo: 'HEY'}
      ctx = new UnicoContext instance, ctrl
      changed = false
      ctx.addChangeListener -> changed = true
      ctx.changed()
      expect(changed).toBeTruthy()


  describe 'digest', ->
    it 'should emit a change event if some watched value changed', ->
      ctrl = {foo: 'HEY'}
      ctx = new UnicoContext instance, ctrl
      changed = false
      ctx.addChangeListener -> changed = true
      ctx.evalAndWatch 'foo'
      ctx.digest()
      expect(changed).toBe false
      ctrl.foo = 'HO'
      ctx.digest()
      expect(changed).toBe true
