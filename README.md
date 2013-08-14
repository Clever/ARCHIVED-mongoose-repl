# mongoose-shell

A Mongo shell with the full power of Mongoose.

If you're using the [Mongoose ODM](http://mongoosejs.com/) to keep your MongoDB code from descending into schema-less chaos, it can be a pain to fall back to the barebones Mongo shell when you want to interact with your data.

`mongoose-shell` registers your schemas and exposes the resulting models in an interactive shell, so you can `findById` and `populate` to your heart's content. You'll never have to type `ObjectId` again. Oh, and did I mention it interprets CoffeeScript?

    $ mongoose-shell --schemas examples/schemas.coffee localhost/test
    > Dog.findById('520bb7baa4e06dc4e9000001').select('enemy name').populate('enemy')
    { name: 'fido',
      enemy: { name: 'fluffy', _id: 520baec9d61fae3ee6000001, __v: 0 },
      _id: 520bb7baa4e06dc4e9000001 }
    > Cat.findById _.enemy._id
    { name: 'fluffy', _id: 520baec9d61fae3ee6000001, __v: 0 }

## Installation

    npm install -g mongoose-shell

## Usage

### Connecting to a DB

To connect to a Mongo instance, simply pass in a [MongoDB connection string](http://docs.mongodb.org/manual/reference/connection-string/):

    $ mongoose-shell localhost/test 
    Connecting to: localhost
    Using db: test
    No models loaded
    >

Now we have access to the Mongoose connection object:

    > conn.host
    'localhost'
    > conn.name
    'test'
    > conn.db
    { domain: null,
      _events: 
       { close: [Function],
         error: [Function],
     ...

### Loading Models

Notice that no models were loaded, so the shell isn't very useful yet. In order for `mongoose-shell` to give you access to Mongoose models, you have to first tell it about your schemas. Create a file that exports a mapping from schema names to schemas, like so:

    $ cat examples/schemas.coffee
```coffeescript
{Schema} = require 'mongoose'
module.exports =
  Cat: new Schema
    name: String
  Dog: new Schema
    name: String
    enemy: { type: Schema.Types.ObjectId, ref: 'Cat' }
```

Now you can load these schemas into the shell using the `--schemas` (`-s`) option, which will register them as Mongoose models:

    $ mongoose-shell --schemas examples/schemas.coffee localhost/test
    Connecting to: localhost
    Using db: test
    Loaded models: Cat, Dog
    > Cat.modelName
    'Cat'

### Querying

This is where things get awesome. Now you can query models just like you do in Mongoose:

    > Dog.findOne().populate('enemy')
    { name: 'fido',
      enemy: { name: 'fluffy', _id: 520baec9d61fae3ee6000001, __v: 0 },
      _id: 520bb7baa4e06dc4e9000001,
      __v: 0 }

The special variable `_` holds the value of the last expression, so you can use it in further queries:

    > Cat.find name: _.enemy.name
    [ { name: 'fluffy', _id: 520baec9d61fae3ee6000001, __v: 0 } ]
