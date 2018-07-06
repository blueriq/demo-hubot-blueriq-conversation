# Description:
#   Chat with your Blueriq server using the Decision Tree API
#
# Configuration:
#   HUBOT_BLUERIQ_RUNTIME_URL
#   HUBOT_BLUERIQ_USERNAME
#   HUBOT_BLUERIQ_PASSWORD
#	HUBOT_BLUERIQ_SHORTCUT
#
# Dependencies:
#   "moment": "^2.10.3"
#
# Commands:
#   None
#
# Author:
#   s.wartenberg
moment = require('moment');
	
module.exports = (robot) ->
	
	robot.hear /hi/i, (msg) ->
		msg.reply "Hello, how can I help you?"	
		return
		
	robot.respond /.*/i, (msg) ->	
		userData = initUserData(msg)
		
		isStarted = userData.startedTree
		currentQuestion = userData.currentQuestion
		selectedTree = userData.selectedTree
		answers = userData.answers
		message = parseMessage(msg)
		
		if(isStarted == true && currentQuestion != null)		
			if(currentQuestion.type == 'date')
				date = moment(message, "YYYY-MM-DD")
				if(date.isValid())
					message = date.format("YYYY-MM-DD")
				else
					msg.reply "Date '" + message + "' is not valid. Please enter a date with the expected format YYYY-MM-DD (e.g. 1980-12-29)."
					return
				
			if(currentQuestion.domain == true)
				selectedDomainValue = (Object.keys(currentQuestion.domainValues).filter (key) -> key == message)[0]
				
				if(selectedDomainValue == undefined)
					msg.reply "Option '" + message + "' is not a valid option. Please choose one of the following options: \n\n" + printDomainValues(currentQuestion)
					return			
			
				message = currentQuestion.domainValues[selectedDomainValue].key
				
			answers.answers.push { key: currentQuestion.key, value: message};
			storeAnswers(msg.message.user.id, answers)
			
			data = JSON.stringify(answers)
			
			execute(msg, selectedTree.name, data)

		else if(isStarted == false && selectedTree == null)
			msg.reply "Let me check my questionnaire database..."
			search(msg, message)	
		
	parseMessage = (msg) ->
		return msg.message.text.replace "@" + robot.name + " ", ""
		
	search = (msg, symptomText) ->	
		userId = msg.message.user.id
		
		data = JSON.stringify({symptomText: symptomText, maximumResults: 1})
		
		url = process.env.HUBOT_BLUERIQ_RUNTIME_URL
		user = process.env.HUBOT_BLUERIQ_USERNAME
		pass = process.env.HUBOT_BLUERIQ_PASSWORD
		shortcut = process.env.HUBOT_BLUERIQ_SHORTCUT
		
		auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64');
		robot.http(url + "/server/api/v1/dtree/search/" + shortcut)
			.headers('Authorization': auth, 'Accept': 'application/json', 'Content-Type': 'application/json', 'Accept-Language': 'en-GB')
			.post(data) (err, res, body) ->
				if err
					msg.reply "I am really sorry but Blueriq says: #{err}"
				else if 200 <= res.statusCode < 400
					return parseSearchResponse(body, userId, msg)
				else
					msg.reply  "Oops! Something went wrong! Blueriq says: Status #{res.statusCode} #{body}"	
			
	execute = (msg, treeName, data) ->	
		userId = msg.message.user.id
		
		url = process.env.HUBOT_BLUERIQ_RUNTIME_URL
		user = process.env.HUBOT_BLUERIQ_USERNAME
		pass = process.env.HUBOT_BLUERIQ_PASSWORD
		shortcut = process.env.HUBOT_BLUERIQ_SHORTCUT
		
		auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64');
		robot.http(url + "/server/api/v1/dtree/execute/" + shortcut + "/" + treeName)
			.headers('Authorization': auth, 'Accept': 'application/json', 'Content-Type': 'application/json', 'Accept-Language': 'en-GB')
			.post(data) (err, res, body) ->
				if err
					msg.reply "I am really sorry but Blueriq says: #{err}"
				else if 200 <= res.statusCode < 400
					msg.reply  parseExecuteResponse(body, userId)
				else
					msg.reply  "Oops! Something went wrong! Blueriq says: Status #{res.statusCode} #{body}"

	parseSearchResponse = (body, userId, msg) -> 
		content = JSON.parse(body)
		
		if(content.trees.length > 0)
			scoredTrees = content.trees.filter (tree) -> tree.score > 0
			
			if(scoredTrees.length == 0)
				msg.reply "Sorry, no match found. Please try again"
				return
			
			tree = scoredTrees[0]
			start(userId, tree)
			
			msg.reply "Found a match for questionnaire '" + tree.description + "'\nStarting first question..."
			
			execute(msg, tree.name, {})
		else
			msg.reply "Sorry, no match found. Please try again"
	
	parseExecuteResponse = (body, userId) -> 
		content = JSON.parse(body)
		
		if(content.solutions.length > 0)
			solution = content.solutions[0]
			stop(userId)
			return printSolution(solution)
		else
			question = content.questions[0]
			storeCurrentQuestion(userId, question)
			return printQuestion(question)
		
	printSolution = (solution) ->	
		line = ""
	
		for part in solution.parts
			if(part.questionText != null)
				line += part.questionText + "\n"
			else
				line += part.value + "\n"
				
		return line.substring(0, line.length - 2)	
			
	printQuestion = (question) ->		
		if(question.domain == true)
			return question.questionText + " Please choose one of the following options: \n\n" + printDomainValues(question)
		else
			return question.questionText
	
	printDomainValues = (question) ->
		line = ""
		domainValues = question.domainValues		
		
		for domainValue, index in domainValues
			line +="[#{index}]: #{domainValue.description} \n"
				
		return line
		
	storeAnswers = (userId, answers) -> 
		userData = robot.brain.get(userId)
		userData.answers = answers
		saveUserData(userId, userData)
			
	storeCurrentQuestion = (userId, question) -> 
		userData = robot.brain.get(userId)
		userData.currentQuestion = question
		saveUserData(userId, userData)
		
	initUserData = (msg) -> 
		userId = msg.message.user.id
		userData = robot.brain.get(msg.message.user.id)
		
		if(userData == null)			
			return stop(userId)
		
		return userData
	
	start = (userId, selectedTree) ->
		userData = reset(true, selectedTree)
		saveUserData(userId, userData)
		
		return userData
		
	stop = (userId) ->
		userData = reset(false, null)	
		saveUserData(userId, userData)
		
		return userData
		
	saveUserData = (userId, userData) ->
		robot.brain.set(userId, userData)
		robot.brain.save()
		
	reset = (started, selectedTree) ->
		return { startedTree : started, selectedTree : selectedTree, currentQuestion : null, answers : {answers : []}}
	