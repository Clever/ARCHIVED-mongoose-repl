spawn = require('child_process').spawn
cli = require '../lib/cli'
assert = require 'assert'

describe "mongoose (cli)", ->
  
  it "connects to host localhost by default", ->
    assert.equal cli.mongo_uri(undefined, 'somedb'), 'localhost/somedb'

  it "connects to db test by default", ->
    assert.equal cli.mongo_uri('somehost', undefined), 'somehost/test'

  it "connects using a host/db connection string", ->
    assert.equal cli.mongo_uri(undefined, 'somehost/somedb'), 'somehost/somedb'

  it "connects using the host option", ->
    assert.equal cli.mongo_uri('somehost', 'somedb'), 'somehost/somedb'

  it "doesn't connect using the host option and a host/db connection string", ->
    assert.throws ->
      cli.mongo_uri('somehost', 'anotherhost/somedb')
    , "url can't have host if you specify it using the --host option"
