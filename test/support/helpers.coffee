# Fixtures
#----------------------------------------------------------------------

addFixture = (html) ->
  div = document.createElement "div"
  div.setAttribute 'id', 'fixture'
  div.innerHTML = html
  document.body.appendChild div

getFixture = ->
  document.getElementById 'fixture'

getFixtureElement = ->
  c = getFixture().children
  if c.length == 1 then return c[0] else return c

cleanFixture = ->
  div = getFixture()
  document.body.removeChild(div) if div


# Clean fixtures after each test
afterEach ->
  cleanFixture()
  # Unistall ajax interceptor
  jasmine.Ajax.uninstall();

# React
#----------------------------------------------------------------------

renderReact = (reactElement) ->
  React.renderToStaticMarkup reactElement

# Factories
#----------------------------------------------------------------------

createCtx = (ctrl={})->
  app = new UnicoApp()
  instance = {app: app}
  new UnicoContext instance, {}

createMeta = (ctx, html) ->
  MetaElement.fromStr ctx, html
