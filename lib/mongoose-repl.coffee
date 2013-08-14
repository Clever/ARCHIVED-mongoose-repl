node_repl = require 'repl'
CoffeeScript = require 'coffee-script'
vm = require 'vm'
_ = require 'underscore'
mongoose = require 'mongoose'
util = require 'util'

# Maps a fn over the values of an object
_.mixin map_values: (obj, f_val) ->
  _.object _.map obj, (val, key) -> [key, f_val(val, key)]

module.exports.run = (schemas, mongo_uri) ->

  console.log "Connecting to: #{mongo_uri}"
  conn = mongoose.createConnection mongo_uri

  models = _.map_values schemas, (schema, name) ->
    # Hack the prototype to use our instance of mongoose instead of the
    # instance that created the schema, since mongoose does an instanceof check
    # internally.
    schema.__proto__ = mongoose.Schema.prototype
    conn.model(name, schema)

  options =
    eval: (cmd, context, filename, cb) ->
      # Node's REPL sends the input ending with a newline and then wrapped in
      # parens. Unwrap all that.
      # (copied from coffee repl)
      cmd = cmd.replace /^\(([\s\S]*)\n\)$/m, '$1'

      js = CoffeeScript.compile cmd, bare: true
      try res = vm.runInContext js, context, filename
      catch err then return cb err

      if res instanceof mongoose.Query then res.exec cb
      else cb null, res

  conn.once 'open', ->
    console.log "Using db: #{conn.name}"
    console.log(
      if _.isEmpty models then "No models loaded"
      else "Loaded models: #{_.keys(models).join(', ')}")

    repl = node_repl.start options
    _.extend repl.context, models
    _.extend repl.context,
      conn: conn

    repl.on 'exit', ->
      repl.outputStream.write '\n'
      process.exit()
