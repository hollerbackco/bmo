# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot + <key> - increment <key> counter
module.exports = (robot) ->
  robot.respond /\+/i, (msg) ->
    msg.send "plus one"
