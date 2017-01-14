express = require 'express'

class RAI

  constructor : ( options ) ->
    @config = options
    @tasks  = []
    @app    = express()
    @server = require( 'http' ).createServer @app
    @io     = require( 'socket.io' ) @server
    @router = null

    @setup()

  setup : ->

  run : ->
    @server?.listen @getPort()
    @log "magic happends on #{ @getPort() }"

  addTask : ( task ) ->
    @tasks.push task

  findTask : ( task ) ->
    @getTasks().find ( t ) ->
      return t._id == task._id

  startTask : ( task ) ->
    if task?.__before
      before = task.__before
      delete task.__before
      @addTask task
      @addTask before

      return @getIo().of( '/gate' ).to( before.type ).emit 'init', before

    isStaged = @getTasks().find( ( t ) -> t._id is task._id )
    
    if not isStaged
      @addTask task

    return @getIo().of( '/gate' ).to( task.type ).emit 'init', task

  removeTask : ( task ) ->
    @tasks.splice @tasks.indexOf( task ), 1

  log : ( msg ) ->
    if @isDebug
      console.log msg
    return

  # getters
  getConfig   : -> @config
  getTimezone : -> @config?.timezone
  getLocale   : -> @config?.locale
  getPort     : -> @config?.port
  getTasks    : -> @tasks
  getApp      : -> @app
  getServer   : -> @server
  getIo       : -> @io

  isDebug     : -> @config?.debug

  # setters
  setConfig : ( @config ) ->
  setTasks  : ( @tasks ) ->

# module.exports = RAI