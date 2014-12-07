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
afterEach -> cleanFixture()



# Factory Meta
#----------------------------------------------------------------------

createMeta = (ctx, html) ->
  el = document.createElement 'div'
  el.innerHTML = html
  new MetaElement ctx, el.childNodes[0]
