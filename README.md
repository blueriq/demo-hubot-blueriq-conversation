[![][logo]][website] 

# About

The scripts in this repository are written for demo purposes. No rights reserved.

# Installing

Once you have [Hubot](https://hubot.github.com/) installed, you can copy 
files from this repository into your `scripts` directory. 

Afterwards, you have to configure the connection to the Blueriq Runtime.

Restart your robot, and you're good to go.

# Configure Blueriq Runtime connection

Hubot needs to know where the Blueriq Runtime exists so the chat can start. 
Please set the following variables and (re)start Hubot. 

SET HUBOT_BLUERIQ_RUNTIME_URL=http://localhost:8080/Runtime/
SET HUBOT_BLUERIQ_USERNAME=admin
SET HUBOT_BLUERIQ_PASSWORD=welcome

# Start chatting

1. Say `hi`. Reply: `Hello, how can I help you?`
2. Say `@<botname> <question>`. Reply: `Let me check my questionnaire database...`. The chat with Blueriq starts.

[logo]: https://www.blueriq.com/wp-content/themes/blueriq_src/assets/images/blueriq_logo.png
[website]: http://www.blueriq.com