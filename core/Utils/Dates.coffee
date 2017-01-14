moment = require 'moment-timezone'

class Dates

  constructor : ( options ) ->
    Object.assign @, options

  toLocal : ( date ) ->
    d = moment()
    d = moment( date ) if date
    d.tz( @getTimezone() ).locale( @getLocale() )

  now : ->
    @toLocal()

  timestamp : ( date ) ->
    parseInt @toLocal( date ).format( 'x' )

  # getters
  getTimezone : -> @timezone
  getLocale   : -> @locale

  # setters
  setTimezone : ( @timezone ) ->
  setLocale   : ( @locale ) ->


# module.exports = Dates