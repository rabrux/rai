class Protocol

  constructor : ( @__smith, @__config ) ->
    @setup()

  setup : () ->
    it = @
    @getIo()
      .of '/gate'
      .on 'connection', ( socket ) ->

        it.log "connected #{ socket.id }"
        socket.emit 'who'

        socket
          .on 'handshake', ( agent ) ->
            it.log "handshake with #{ agent.type }"
            room = agent.type
            socket.join room
            it.log "agent join to room #{ room }"

            it.getIo()
              .of '/gate'
              .in room
              .clients ( err, agents ) ->
                throw err if err
                
                socket.emit 'join',
                  name   : room
                  length : agents.length

          .on 'accept', ( task ) ->
            task = it.getAgent().findTask task
            task.accepted = true
            it.log "agent #{ task.type } accepted task #{ task._id }"
            it.getIo()
              .of '/gate'
              .to socket.id
              .emit 'exec', task._id

          .on 'end', ( result ) ->
            return throw 'RESULT_FAILED' if not result?._id
            task = it.getAgent().findTask _id : result._id

            it.getAgent().removeTask( task )

            console.log 'TASK_BUFFER', it.getAgent().getTasks().length

            if task?.__next
              next = it.getAgent().findTask _id : task.__next
              res  = next?.res
              delete result._id
              delete next.res
              Object.assign next, result
              it.getAgent().startTask( next )
              next.res = res
              return

            return task?.res?.send result

          .on 'err', ( err ) ->
            task = it.getAgent().findTask _id : err._id

            if not task?.__next and task?.res
              it.removeTask task
              return task?.res?.status( err.code || 500 )?.send err.msg || ''

            if task?.__next
              it.removeTask task
              after = it.getAgent().findTask _id : task.__next
              it.removeTask after
              return after?.res?.status( err.code || 500 )?.send err.msg || ''

          .on 'disconnect', ->
            it.log "disconnected client   #{ socket.id }"
            return


  removeTask : ( task ) ->
    @getAgent().tasks.splice @getAgent().tasks.indexOf( task )

  isDebug : -> @__config?.debug

  getAgent : -> @__smith
  getIo    : -> @getAgent().getIo()

  log : ( msg ) ->
    if @isDebug()
      console.log msg

  warn : ( msg ) ->
    if @isDebug()
      console.error msg

# module.exports = Protocol