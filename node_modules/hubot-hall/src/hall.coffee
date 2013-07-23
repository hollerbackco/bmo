# Hubot dependencies
{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response} = require (process.env.HUBOT_HALL_REQUIRE_PATH || 'hubot')

# Hall dependencies
hall = require 'hall-client'

class Hall extends Adapter
		
	send: (params, strings...) ->
		user = @userFromParams(params)
		@bot.sendMessage user.room, str for str in strings

	reply: (params, strings...) ->
		user = @userFromParams(params)
		strings.forEach (str) =>
			@send params, "@#{user.name}: #{str}"
			
	userFromParams: (params) ->
		# hubot < 2.4.2: params = user
		# hubot >= 2.4.2: params = {user: user, ...}
		if params.user then params.user else params
		
	connect: ->
		
		@socket = @bot.socket
		
		onFeedItemCreate = (message) =>
			data = JSON.parse(message).data
			unless !data
				items = data.feed_items
				for item in items
					author =
						id: item.author_id
						name: item.full_name
						room: item.hall_uuid
					return if @bot.get('id') == author.id
					regex_bot_name = new RegExp("^@?#{@robot.name}(,|\\b)", "i")
					regex_user_name = new RegExp("^@?#{@bot.get 'full_name'}(,|\\b)", "i")
					if item.message.match(regex_bot_name)
						hubot_msg = item.message.replace(regex_bot_name, "#{@robot.name}:")
					else if item.message.match(regex_user_name)
						hubot_msg = item.message.replace(regex_user_name, "#{@robot.name}:")
					@receive new TextMessage(author, hubot_msg) if hubot_msg
			
		@socket.on 'firehose:feed_item_create', onFeedItemCreate
		
	run: ->
		
		cfg =
			email:		process.env.HUBOT_HALL_EMAIL
			password:	process.env.HUBOT_HALL_PASSWORD
			
		unless cfg.email and cfg.password
			console.error "ERROR: No credentials in environment variables HUBOT_HALL_LOGIN_EMAIL and HUBOT_HALL_LOGIN_PASSWORD"
			@emit "error", "No credentials"
			
		@bot = new hall.Session(cfg)
		@bot.on 'socketReady', () =>
			@connect()
			@emit 'connected'

exports.use = (robot) ->
	new Hall robot
