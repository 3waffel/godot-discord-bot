# Godot Discord Bot 

> Integrated with [OpenAI API](https://beta.openai.com/docs/api-reference/making-requests)

## Setup

Host the bot on Heroku using [Godot buildpack](https://github.com/3waffel/heroku-buildpack-godot).

Get token from OpenAI, then set `OPENAI_TOKEN` in Heroku -> Settings -> Config Vars  

## Usage

+ chat  (OpenAI completion feature)  
  `/chat content: post a long article to introduce GPT-3.`

## Request Body
```
{
  "prompt": "Say this is a test",
  "max_tokens": 5,
  "temperature": 1,
  "top_p": 1,
  "n": 1,
  "stream": false,
  "logprobs": null,
  "stop": "\n"
}
```

## Credits

[discord.gd](https://github.com/3ddelano/discord.gd)
