define (require, exports, module) ->
  describe 'UnicoApp', ->
    describe 'render', ->
      it 'should create instances for each controller in the given dom', ->
        React = require('react')
        addFixture '''
        <div controller="test">
          {{fieldFoo}}
        </div>
        '''
        class TestController
          fieldFoo: 'FOO'

        app = new UnicoApp()
        app.addController 'test', TestController
        app.build()
        expect(app.instances.length).toBe 1
