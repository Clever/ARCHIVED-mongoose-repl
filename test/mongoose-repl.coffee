
mongoose = require 'mongoose'
spawn = require('child_process').spawn
assert = require 'assert'
cmd = require('path').resolve(__dirname + '/../run.js')

describe 'mongoose-repl', ->

  before (done) ->
    mongoose.connect 'mongodb://localhost/mongoose-repl-test', (err) ->
      done(err)

  after ->
    mongoose.disconnect()

  beforeEach (done) ->
    schema = require('./fixtures/schemas.coffee').Cat
    Cat = mongoose.model('Cat', schema)
    Cat.remove {}, (err) -> 
      if err
        done err
        return
      Cat.create [{ name: 'Tom' }, { name: 'Foo' }, { name: 'Bar' }], (err) -> 
        done(err)

  test = (command, cb) ->
    out = ''
    repl = spawn 'node', [cmd, '--schemas', __dirname + '/fixtures/schemas.coffee', 'mongoose-repl-test']
    repl.stdout.on 'data', (data) ->
      out+=data
    repl.stderr.on 'data', (err) ->
      cb(err)
    
    repl.stdin.write command
    intervalId = setInterval (-> 
      if />[\s\S]*>/.test(out)
        repl.stdin.write '.exit\n'
        clearInterval(intervalId)
    ), 100
      
    repl.on 'exit', ->
      res = />([\s\S]*)>/.exec(out)[1]
      cb(null, res)

  it "finds docs", (done) ->
    test 'Cat.find()\n', (err, out) ->
      done(err) if err
      assert.ok /Tom/.test(out)
      assert.ok /Foo/.test(out)
      assert.ok /Bar/.test(out)
      done()

  it "finds with condition", (done) ->    
    test 'Cat.find({ name: \'Tom\' })\n', (err, out) ->
      done(err) if err
      assert.ok /Tom/.test(out)
      assert.ok !/Foo/.test(out)
      assert.ok !/Bar/.test(out)
      done()

  it.skip "finds with RegExp in condition", (done) ->
    test 'Cat.find({ name: /.o./ })\n', (err, out) ->
      done(err) if err
      assert.ok /Tom/.test(out)
      assert.ok /Foo/.test(out)
      assert.ok !/Bar/.test(out)
      done()