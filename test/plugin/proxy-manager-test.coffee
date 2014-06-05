{ProxyManager} = require '../../src/proxy-manager'
{Browser} = require '../../src/browser'

testPackages = require '../testdata/packages.json'
testServers = require '../testdata/servers.json'

describe 'Proxy Manager', ->
  beforeEach ->
    this.sandbox = sinon.sandbox.create()

    this.proxyClearStub = this.sandbox.stub(Browser, 'clearProxy')
    this.proxySetStub = this.sandbox.stub(Browser, 'setProxyAutoconfig')

  afterEach ->
    this.sandbox.restore()

  describe 'Script generation', ->
    it 'should generate the correct routing script', ->
      testConfigs = [{
        "startsWith": "",
        "contains": [],
        "host": "google.co.uk"
      },
      {
        "startsWith": "",
        "contains": ['also contains', 'multiple things'],
        "host": "google.com"
      },
      {
        "startsWith": "startswith",
        "contains": ['contains'],
        "host": "google.com"
      }]

      testResults = [
        "(host == 'google.co.uk')",
        "(url.indexOf('also contains') != -1 && url.indexOf('multiple things') != -1 && host == 'google.com')",
        "(shExpMatch(url, 'startswith*') && url.indexOf('contains') != -1 && host == 'google.com')"
      ]

      i = 0
      while(i < testConfigs.length)
        assert.equal(testResults[i], ProxyManager.parseRoutingConfig(testConfigs[i]))
        i += 1

    it 'should generate the correct proxy autoconfig', ->
      parseRoutingConfigSpy = this.sandbox.spy(ProxyManager, 'parseRoutingConfig')
      # We remove the random element and directly join the string, to be able to compare the result
      generateAndScrumbleServerStringStub = this.sandbox.stub(ProxyManager, 'generateAndScrumbleServerString', (serverArray) ->
        return "PROXY #{serverArray.join('; PROXY ')}"
      )

      # Check if the routing generator got called for every server routing element available
      actualConfig = ProxyManager.generateProxyAutoconfigScript(testPackages, testServers)
      routeAmounts = 0
      for pkg in testPackages
        routeAmounts += pkg.routing.length
        for packageRoute in pkg.routing
          assert.isTrue(parseRoutingConfigSpy.calledWith(packageRoute), 'called the config generator with the correct parameter')

      assert.equal(routeAmounts, parseRoutingConfigSpy.callCount)

      # Compare the pac script result
      expectedConfig = "function FindProxyForURL(url, host) {if ((url.indexOf('vevo.com') != -1 && url.indexOf('vevo2.com') != -1) || (shExpMatch(url, 'http://www.beatsmusic.com*'))) { return 'PROXY einsvonzwei.de:8080; PROXY zweivonzwei.de:8080' } else if ((host == 'www.google.com') || (host == 'another.com')) { return 'PROXY anothercountry.de:8080' } else { return 'DIRECT'; }}"
      assert.equal(expectedConfig, actualConfig)

      # Count if the scrumbleServers got called the right amount of times
      serverCountries = {}
      for server in testServers
        serverCountries[server.country] = true

      assert.equal(Object.keys(serverCountries).length, generateAndScrumbleServerStringStub.callCount)
      parseRoutingConfigSpy.restore()
      generateAndScrumbleServerStringStub.restore()

  describe 'Proxy setting / removing behaviour', ->
    it 'should set the proxy correctly', ->
      proxyString = 'asdf'

      ProxyManager.setProxyAutoconfig(proxyString)

      assert.isTrue(this.proxySetStub.calledOnce)
      assert.isTrue(this.proxySetStub.calledWith(proxyString))

      ProxyManager.clearProxy()
      assert.isTrue(this.proxyClearStub.calledOnce)
