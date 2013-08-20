path = require 'path'
repl = require './lib-js/mongoose-repl'
argv = require("optimist")
  .usage('mongoose [options] <mongo url>')
  .options(
    schemas:
      alias: '-s'
      describe: 'Path to a module that exports schema definitions'
    host:
      alias: '-h'
      describe: 'Host to connect to'
  ).argv

schemas = if argv.s? then require path.resolve argv.s else {}
host = argv.host ? 'localhost'
db = argv._?[0] ? 'test'
if '/' in db
  throw new Error "url can't have host or port if you specify them individually" if argv.host?
  [host, db] = db.split '/'

repl.run schemas, "#{host}/#{db}"
