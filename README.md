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
Please set the following variables in bin\hubot.cmd and (re)start Hubot. 

```bash
SET HUBOT_BLUERIQ_RUNTIME_URL=http://localhost:8080/Runtime
SET HUBOT_BLUERIQ_USERNAME=admin
SET HUBOT_BLUERIQ_PASSWORD=welcome
SET HUBOT_BLUERIQ_SHORTCUT=coffee
```

# Set up Blueriq Runtime

Chat with your Blueriq server using the Decision Tree API (available since Blueriq 11.2).

In Blueriq Studio 11.2 or higher we have provided an example package called `CoffeeAdvisor.package`.
After importing this in your project, please create a shortcut in the `application.properties`:

```
blueriq.shortcut.coffee.project=studio-Demo-CoffeeAdvisor
blueriq.shortcut.coffee.version=0.0-Trunk
blueriq.shortcut.coffee.securityEnabled=true
```

Because we enabled the security, make sure an authentication provider is present. For example:

```
blueriq.security.auth-providers.local01.type=in-memory
blueriq.security.auth-providers.local01.users.location=aquima://users.properties
blueriq.security.auth-providers-chain=local01
```

In the example above, please add `users.properties` in the `spring.config.additional-location` and add the user:

```
admin={noop}welcome,admin
```

# Start chatting

1. Say `hi`. Reply: `Hello, how can I help you?`
2. Say `@<botname> What kind of coffee do I need?`. Reply: `Let me check my questionnaire database...`. The chat with Blueriq starts.

[logo]: https://www.blueriq.com/wp-content/uploads/2018/07/BLUERIQ-rgb-logo-kleur-gradient-PNG-300x111.png
[website]: http://www.blueriq.com
