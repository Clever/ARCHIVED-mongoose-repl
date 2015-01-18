{Schema} = require 'mongoose'
module.exports =
  Cat: new Schema
    name: String
  Dog: new Schema
    name: String
    enemy: { type: Schema.Types.ObjectId, ref: 'Cat' }
