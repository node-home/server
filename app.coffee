require('dotenv').load()

home    = require 'home'
flow    = require 'home.flow'
voice   = require 'home.voice'
aura    = require 'home.aura'
wire    = require 'home.wire'
express = require 'home.express'

do home.init

hue = home.apps.aura.hue

express.app.get '/wit', (req, res) ->
  res.status(400).json 'missing q parameter' unless req.query.q

  voice.wit.parse(req.query.q)
    .then (outcome) ->
      flow.hub.emit outcome.intent, outcome.entities
      res.json outcome
    .catch (error) ->
      console.log arguments
      # TODO get status code from error
      res.status(400).json error

flow.hub.on 'wire_send', ({contact, message_body}) ->
  console.log "wire.send", contact[0], message_body[0]
  wire.send contact[0], message_body[0]

flow.hub.on 'lights_toggle', ({toggle, light, ms}) ->
  aura.light.off(toggle[0], light[0], ms[0])

flow.hub.on 'lights_off', ({light, ms}) ->
  aura.light.off(light[0], ms[0])

flow.hub.on 'lights_on', ({light, ms}) ->
  aura.light.on(light[0], ms[0])
