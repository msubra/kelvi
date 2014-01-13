#get the instance of localstorage. if not available, localStorage may not be supported, so get cookie storage
try
	jaadi = Jaadi.createInstance("localstorage")
catch
	jaadi = Jaadi.createInstance("dom")

dabba = jaadi

GlobalConfig=

	usertopics:['java','jquery','javascript','python'],
	
	useUserSettings: false

	default:{
		questionsCount: 8,
		refreshRate: 10*60*1000 #10mins
		watches:
			"active" : {
				"title":"active",
				"category": "active",
				"url":"https://api.stackoverflow.com/1.1/questions",
				"query": {"tagged":"__TOPIC__"},
				"show":true,
				"enable" : true
			}
		
			"new" : {
				"title":"new",
				"category": "new",
				"url":"https://api.stackoverflow.com/1.1/questions",
				"query": {"sort":"creation","order":"desc","tagged":"__TOPIC__"},
				"show":false,
				"enable" : true
			}

			"featured" : {
				"title":"featured", 
				"category": "featured",
				"url":"https://api.stackoverflow.com/1.1/questions", 
				"query": {"sort":"featured","order":"asc","tagged":"__TOPIC__"},
				"show":false,
				"enable" : true
			}

			"unanswered" : {
				"title":"unanswered", 
				"category": "unanswered",
				"url":"https://api.stackoverflow.com/1.1/questions/no-answers", 
				"query": {"sort":"votes","order":"desc","tagged":"__TOPIC__","pagesize": 50},
				"show":false,
				"enable" : true
			}
	}

	topics:
		java :
			topic: "java"
		jquery :
			topic: "jquery"
		javascript : 
			topic: "javascript"
		python : 
			topic: "python"


# save the object
saveConfig = () ->
	dabba.put("KelviCfg",GlobalConfig)
	

#load the object
loadConfig = () ->
	if dabba.get("KelviCfg") != null	#use the one from local cache
		GlobalConfig = dabba.get("KelviCfg")
	else
		for k,topic of GlobalConfig.topics
			cfg = getConfig k
			GlobalConfig.topics[k] = cfg


updateConfig = (topic) ->
	#create the topic
	GlobalConfig.topics[topic] = { "topic":topic}

	#create the config
	GlobalConfig.topics[topic] = getConfig topic

	#save the config
	saveConfig()

compareAndCopy = (target_map,default_map) ->

	for k,v of default_map	#for all keys in default

		if not (k of target_map)	#if key is not available in target, then copy entire value to target
			if typeof v is "object" #if 'v' is object then, clone it to de-reference
				target_map[k] = jQuery.extend(true, {}, v); 
			else
				target_map[k] = v
		else	#if there is a key available, check if all the child attributes are available
			if typeof(v) is "object"
				compareAndCopy(target_map[k],v)				

	return target_map

getConfig = (topic) ->
	common_cfg = GlobalConfig.default
	if topic of GlobalConfig.topics
		cfg  = GlobalConfig.topics[topic]

		# clone the cfg, so that configs are not polluted
		cloned_cfg = jQuery.extend(true, {}, cfg);

		# now compare and copy
		cloned_cfg = compareAndCopy cloned_cfg,common_cfg

		#update the tagged attribute in watch
		for k,w of cloned_cfg.watches
			w.query.tagged = topic

		return cloned_cfg

	return common_cfg


#load the config before app init
loadConfig()