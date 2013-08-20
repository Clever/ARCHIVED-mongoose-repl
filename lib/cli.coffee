path = require 'path'
repl = require "#{__dirname}/mongoose-repl"
optimist = require "optimist"

module.exports =

  schemas: schemas = (schema_path) ->
    if schema_path? then require path.resolve schema_path else {}

  mongo_uri: mongo_uri = (host, db) ->
    if db and '/' in db
      if host? then throw new Error "url can't have host if you specify it using the --host option"
      db
    else "#{host ? 'localhost'}/#{db ? 'test'}"

  run: ->
    argv = optimist
      .usage('mongoose [options] <mongo url>')
      .options(
        schemas:
          alias: '-s'
          describe: 'Path to a module that exports schema definitions'
        host:
          alias: '-h'
          describe: 'Host to connect to'
      ).argv
    repl.run schemas(argv.s), mongo_uri(argv.h, argv._?[0])
