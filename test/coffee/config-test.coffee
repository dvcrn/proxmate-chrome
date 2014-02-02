define 'TextMock', ->
  return {
    load: (path, req, onLoad, config) ->
      returnArray = {
        "primary_server": "http://127.0.0.1/"
      }
      onLoad(JSON.stringify(returnArray))
  }

require.config
  map:
    'config':
      'text': 'TextMock'

define ['config'], (ConfigProvider) ->
  describe 'Config loader', ->

    after ->
      require.config({map: {}})
      require.undef('TextMock')


    it 'should return config content correctly', ->
      # We'll not test the text plugin here. We assume it works.
      ConfigProvider.init()
      assert.equal('http://127.0.0.1/', ConfigProvider.get('primary_server'))