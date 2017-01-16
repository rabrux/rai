randomstring = require 'randomstring'
path         = require 'path'

class Task

  constructor : ( task ) ->
    @_id       = @newId()
    @type      = String
    @cmd       = String
    @args      = {}
    @startedAt = Number
    @path      = String
    @ended     = false
    @__token   = String
    @__level   = String

    Object.assign @, task
    @init()

  init : ->
    if not @path
      return throw 'path is required'
    
    items = @path.split( path.sep )
    items.shift()
    if items.length >= 2
      @type = items.shift()
      @cmd  = items.shift()
    else
      return throw 'path must be http://../[agent]/[command]'

  newId : ->
    randomstring.generate
      length  : 32
      charset : 'alphanumeric'

  # getters
  getId    : -> @_id
  getType  : -> @type
  getCmd   : -> @cmd
  getArgs  : -> @args
  getToken : -> @__token
  getLevel : -> @__level
  getUser  : ( cb ) ->
    token = @getToken()
    if not token
      return @end 
        _id     : task._id
        __level : '*'
      
    secret = @getSecret()
    try
      decoded = jwt.decode token, secret
    catch e
      return cb e, null

    return cb null, decoded
  # setters
  setId    : ( @_id )     ->
  setType  : ( @type )    ->
  setCmd   : ( @cmd )     ->
  setArgs  : ( @args )    ->
  setToken : ( @__token ) ->
  setLevel : ( @__level ) ->

# module.exports = Task