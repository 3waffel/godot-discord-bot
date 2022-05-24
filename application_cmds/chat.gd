extends Reference

var awaitInteraction: DiscordInteraction = null
var req: HTTPRequest = HTTPRequest.new()
var token: String = ""
var botRef: DiscordBot = null

func execute(main, bot: DiscordBot, interaction: DiscordInteraction, options: Array) -> void:
	if awaitInteraction != null:
		interaction.reply({"content":"Request too frequent."})
		return
	if botRef == null:
		botRef = bot

	if (!req.is_inside_tree()):
		main.add_child(req)
		req.connect("request_completed", self, "on_request_completed")

	if token == null || token == "":
		var e = get_token()
		if e != OK:
			interaction.reply({"content": "Can't get token: `%s`" % e})
			return

	var query = JSON.print({"prompt": options[0].value, "max_tokens": 4000})
	var err = req.request("https://api.openai.com/v1/engines/text-davinci-002/completions",
		[
			"Content-Type: application/json",
			"Authorization: Bearer " + token
		],
		true,
		HTTPClient.METHOD_POST,
		query)
	if err != OK:
		interaction.reply({"content": "Error when setting up request: `%s`" % err})
		return

	awaitInteraction = interaction
	awaitInteraction.reply({
		"content": "Now loading...",
	})

var data = ApplicationCommand.new()\
	.set_name("chat")\
	.set_description("chat with AI")\
	.add_option(ApplicationCommand.string_option("content", "What do you want to say?", {
		"required": true,
	}))

func on_request_completed(result, response_code, headers, body) -> void:
	var text: String = "";
	if result == HTTPRequest.RESULT_SUCCESS:
		var res = JSON.parse(body.get_string_from_utf8())
		text = res.result["choices"][0]["text"]
		if text == "" || text == null:
			text = "No response..."
	else:
		text = "Error when getting response: `%s`" % result

	if awaitInteraction != null:
		if len(text) > 2000:
			var channelId = awaitInteraction.channel_id
			while len(text) > 2000:
				var subText = text.substr(0, 1999);
				var index = subText.find_last(" ")
				if index == -1:
					index = 1999
				text = text.substr(index + 1)
				subText = subText.substr(0, index)
				yield(botRef.send(channelId, subText), "completed")
			yield(botRef.send(channelId, text), "completed")
			awaitInteraction.delete_reply()
		else:
			awaitInteraction.edit_reply({
				"content": text
			})
		awaitInteraction = null
	pass

func get_token():
	var file = File.new()
	var err = file.open("res://openai.secret", File.READ)
	if err == OK:
		token = file.get_as_text()
	elif token == null or token == "":
		if OS.has_environment("OPENAI_TOKEN"):
			token = OS.get_environment("OPENAI_TOKEN")
		else:
			push_error("You need to set the environment variable OPENAI_TOKEN")
			return ERR_CANT_OPEN
	return OK