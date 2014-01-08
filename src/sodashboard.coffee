
toQueryString = (params) ->
	qs = ""
	for k,v of params
		qs += "#{k}=#{encodeURIComponent v}&"

	return qs

class KelviDashboard extends Dashboard

SYMBOL_CODE_MAP =
	"#" : "_hash_"
	"+" : "_plus_"
	"-" : "_minus_"
	"$" : "_dollar_"
	"%" : "_percent_"
	"." : "_dot_"

###
Fetch the config for the given topic. If a 'topic' is not found, then return the default settings.
If a topic has its own settings, verify it has all required settings. Any attribute not found, derive it from 'default'
###


class KelviTopic extends Panel

	hooks =
		"dataloadInit" : () ->
		"dataloadComplete" : () ->
		"dataLoader" : () ->
		
	
	for hook,fn of hooks
		KelviTopic.prototype[hook] = fn

	watches : () -> 
		output = []
		for k in @_watches
			w = @_watches[k]
			if "enable" of k and k.enable is false then continue
			output.push(k)
		
		return output

	getConfig : () ->
		common_cfg = GlobalConfig.default
		if @topic of GlobalConfig.topics
			cfg  = GlobalConfig.topics[@topic]

			# clone the cfg, so that configs are not polluted
			cloned_cfg = jQuery.extend(true, {}, cfg);

			# now compare and copy
			cloned_cfg = compareAndCopy cloned_cfg,common_cfg

			#update the tagged attribute in watch
			for k,w of cloned_cfg.watches
				w.query.tagged = @topic

			return cloned_cfg

		return common_cfg
	
	constructor: (@topic,url,@count,refresh)  ->
		
		@response = {}

		@config = @getConfig()

		@config.questionsCount = @count = @count or @config.questionsCount
		@config.refreshRate = refresh = refresh or @config.refreshRate
		
		console.log @config

		super(@topic,{"config":@config})

		# convert map to array
		w = @config.watches
		@_watches = []
		for k,v of w
			@_watches.push(v)

			


	getURL: (watchConfig) ->
		qs = toQueryString(watchConfig.query)
		"#{watchConfig.url}?#{qs}"
	
	questions: (watch) -> @response[watch]

	show: (watchToShow) ->
		for w in @watches()
			if watchToShow.category == w.category
				w.show = true
			else
				w.show = false

	init: () ->
		# Register the custom callback that the SO will use it and $http will invoke it

		###
		answer_count: 2
		community_owned: false
		creation_date: 1388108504
		down_vote_count: 0
		favorite_count: 0
		last_activity_date: 1388111290
		last_edit_date: 1388108600
		owner: Object
		question_answers_url: "/questions/20793590/answers"
		question_comments_url: "/questions/20793590/comments"
		question_id: 20793590
		question_timeline_url: "/questions/20793590/timeline"
		score: 0
		tags: Array[4]
		title: "Binding json, that has a list, with an object using Jackson"
		up_vote_count: 0
		view_count: 9
		###


		transformQuestions = (data) =>
			questions = []
			for qn in data['questions']

				if 'closed_reason' of qn
					continue

				questions.push(
					question_id:qn.question_id,
					title:qn.title,
					url:qn.question_answers_url
					up_vote: qn.up_vote_count,
					down_vote: qn.down_vote_count,
					answers: qn.answer_count,
					bounty: if ('bounty_closes_date' of qn) and qn.bounty_closes_date*1000 <= new Date().getTime() and ('bounty_amount' of qn) then qn.bounty_amount else null
				)

				if questions.length >= @count
					break

			return questions


		for watch in @_watches
			if not watch.enable is true then continue
			callback_name = "callback_#{@encodedCallbackName()}_#{watch.category}"

			do(callback_name,watch,@response,@dataloadComplete) =>
				console.log "creating #{callback_name}"
				window[callback_name] = (data) =>
					if @dataloadComplete and typeof(@dataloadComplete) == 'function' then @dataloadComplete()	#invoke the init handler
					response[watch.category] = transformQuestions(data)
					return


		#hookup refresh frequency
		do(_this=@,refreshRate=@config.refreshRate) ->
			window.setInterval ()->
				_this.update()
			,refreshRate

	
	encodedCallbackName : () ->
		# replace all symbols to text equivalent using SYMBOL_CODE_MAP
		callback_topic = @topic
		matches = callback_topic.match(/[$%#.+-]/g) or []

		for match in matches
			callback_topic = callback_topic.replace(match,SYMBOL_CODE_MAP[match])
			console.log("matches",match,callback_topic)

		return callback_topic

	update: () ->

		for watchCfg in @_watches
			url = this.getURL(watchCfg)
			encodedTopic = encodeURIComponent @topic
			url = "#{url}callback=JSON_CALLBACK&jsonp=callback_#{@encodedCallbackName()}_#{watchCfg.category}"

			if @dataLoader and typeof(@dataLoader) == 'function'
				if @dataloadInit and typeof(@dataloadInit) == 'function' then @dataloadInit()	#invoke the init handler
				@dataLoader(url)

		return
