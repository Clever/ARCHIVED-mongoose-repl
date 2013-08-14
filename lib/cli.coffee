path = require 'path'
shell = require './lib-js/mongoose-shell'
argv = require("optimist")
  .usage('mongoose-shell [options] <mongo url>')
  .options(
    schemas:
      alias: '-s'
      describe: 'Path to a module that exports schema definitions'
  ).argv

schemas = if argv.s? then require path.resolve argv.s else {}
mongo_uri = argv._?[0] ? 'localhost'

shell.run schemas, mongo_uri
