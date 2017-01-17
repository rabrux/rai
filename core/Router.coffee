bodyParser   = require 'body-parser'
morgan       = require 'morgan'

# Task         = require './Task'
# Dates        = require './Utils/Dates'

class Router

  constructor : ( @__smith ) ->
    @getApp().use bodyParser.urlencoded( { extended: true } )
    @getApp().use bodyParser.json()
    @getApp().use ( req, res, next ) ->
      res.header 'Access-Control-Allow-Origin', '*'
      res.header 'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      res.header 'Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE'
      next()
    @getApp().use morgan( '-> :date[clf] :method :url :status :response-time ms - :res[content-length]' )
    @setup()

  setup : ->
    # setup date utils
    @dates = new Dates
      timezone : @getAgent().getTimezone()
      locale   : @getAgent().getLocale()

    it = @
    @getApp().use ( req, res, next ) ->

      if req.method is 'OPTIONS'
        console.log 'OPTIONS'
        return res.send()

      token = it.getToken( req.headers )

      task = new Task
        __token   : token
        path      : req.path
        startedAt : it.dates.timestamp()
        args      : Object.assign req.body, req.query
        startedAt : it.dates.timestamp()
        res       : res
      
      task.__before = new Task
        __token   : token
        path      : '/auth/level'
        startedAt : it.dates.timestamp()
        __next    : task._id

      it.startTask task

  startTask : ( task ) ->
    @getAgent().startTask( task )

  # getters
  getApp : -> @getAgent()?.app

  getAgent : -> @__smith

  getToken : ( headers ) ->
    if not headers or not headers?.authorization
      return null

    parts = headers.authorization.split ' '
    if parts.length is 2
      return parts[ 1 ]

    null

# module.exports = Router