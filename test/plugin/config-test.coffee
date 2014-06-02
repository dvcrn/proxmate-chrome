{Config} = require '../../src/config'

describe 'Config loader', ->

  it 'should return config content correctly', ->
    Config.init()
    assert.equal('http://api.proxmate.me', Config.get('primary_server'))
