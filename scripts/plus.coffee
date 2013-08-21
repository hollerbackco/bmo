# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot + <key> - increment <key> counter
#   hubot count <key> - print <key> counter
#   hubot count-reset <key> - reset <key> counter

module.exports = (robot) ->
  robot.brain.data.counters = {}

  counter =
    increment: (key) ->
      count = robot.brain.data.counters[key]
      count = if count?
        count[key] += 1
      else
        1
      counter.set key, count

    get: (key) ->
      if counter.hasKey key
        robot.brain.data.counters[key]
      else
        counter.set key, 0

    set: (key,value=0) ->
      robot.brain.data.counters[key] = value

    hasKey: (key) ->
      robot.brain.data.counters[key]?

    reset: (key) ->
      delete robot.brain.data.counters[key]
      true

  robot.respond /count (.*)$/i, (msg) ->
    key = msg.match[1]
    count = counter.get(key)
    msg.send "\"#{key}\" count: #{count}"

  robot.respond /\+ (.*)$/i, (msg) ->
    key = msg.match[1]
    count = counter.increment(key)
    msg.send "\"#{key}\" count: #{count}"

  robot.respond /count-reset (.*)$/i, (msg) ->
    key = msg.match[1]
    counter.reset(key)
    msg.send "reset \"#{key}\": 0"
