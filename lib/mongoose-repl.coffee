node_repl = require 'repl'
CoffeeScript = require 'coffee-script'
vm = require 'vm'
_ = require 'underscore'
util = require 'util'
history = require 'repl.history'

# Maps a fn over the values of an object
_.mixin map_values: (obj, f_val) ->
  _.object _.map obj, (val, key) -> [key, f_val(val, key)]

inspect = (val) ->
  val = val?.toObject?() ? val # toObject prettifies docs
  util.inspect val, { depth: null, colors: true }

writer = (val) ->
  if _.isArray val then "[#{_.map(val, inspect).join(',\n')}]"
  else inspect val

format_error = (err) ->
  # Node's REPL thinks SyntaxErrors are attempts at multi-line, so we dodge
  name = if err.name is 'SyntaxError' then 'Syntax Error' else err.name
  "#{name}: #{err.message}"

module.exports.run = (schemas, mongoose, mongo_uri) ->

  console.log "Connecting to: #{mongo_uri}"
  conn = mongoose.createConnection mongo_uri

  models = _.map_values schemas, (schema, name) ->
    # Hack the prototype to use our instance of mongoose instead of the
    # instance that created the schema, since mongoose does an instanceof check
    # internally.
    schema.__proto__ = mongoose.Schema.prototype
    conn.model(name, schema)

  options =
    useColors: true
    writer: writer
    eval: (cmd, context, filename, cb) ->
      # Node's REPL sends the input ending with a newline and then wrapped in
      # parens. Unwrap all that.
      # (copied from coffee repl)
      cmd = cmd.replace /^\(([\s\S]*)\n\)$/m, '$1'

      try
        js = CoffeeScript.compile cmd, bare: true
        res = vm.runInContext js, context, filename
      catch err then return cb format_error err

      if res instanceof mongoose.Query
        res.setOptions(slaveOk: true).exec (err, doc) -> cb err, doc
      else
        cb null, res

  conn.once 'open', ->
    console.log "Using db: #{conn.name}"
    console.log(
      if _.isEmpty models then "No models loaded"
      else "Loaded models: #{_.keys(models).join(', ')}")

    repl = node_repl.start options
    _.extend repl.context, models
    _.extend repl.context,
      conn: conn
      ObjectId: conn.base.Types.ObjectId
      inspect: (val...) -> console.log _.map(val, inspect).join(', ')

    history repl, "#{process.env.HOME}/.mongoose_history"

    repl.on 'exit', ->
      repl.outputStream.write '\n'
      process.exit()
