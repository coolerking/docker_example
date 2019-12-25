# Commands:
#  hubot hello

module.exports = (robot) ->
  robot.respond /hello$/i, (msg) ->
    msg.send "World"
