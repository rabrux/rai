class Rai extends RAI

  setup : ->
    @__router   = new Router @
    @__protocol = new Protocol @, @getConfig()

module.exports = Rai