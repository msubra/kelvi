###
Defines various custom events
	- Loops
###
angular.module('CustomEvents',[]).directive('loopEvents', () ->
	(scope, element, attrs) ->
		if (scope.$first)
			#publish when iteration starts
			scope.$emit("ng-repeat:start", {"element":element[0],"attrs":attrs})

		if (scope.$last)
			#publish when iteration is completes
			scope.$emit("ng-repeat:complete", {"element":element[0],"attrs":attrs})

		return
)


###
	Load custom events for event handling
###
Kelvi = angular.module('Kelvi',['CustomEvents'])


Kelvi.controller 'KelviController',($scope,$http) ->

	$scope.SO_URL = 'https://stackoverflow.com'

	$scope.$on "ng-repeat:complete", () -> $scope.changeHeight()

	$scope.SETTINGS = GlobalConfig

	$scope.panels = []

	### Setup shortcuts ###
	$scope.get = (prop) ->
		$scope.SETTINGS[prop] or null

	$scope.topics = ()-> GlobalConfig.topics

	$scope.dashboard = new KelviDashboard "Stacks"

	$scope.addTopic = (topic) =>
		panel = new KelviTopic topic

		#hook up the data loader function
		panel.dataLoader = (url) -> $http.jsonp(url)

		$scope.dashboard.addPanel panel

	$scope.questions_watch = (panel,watch) -> panel.questions(watch.category)

	$scope.questions = (panel) -> 
		for watch in panel.watches()
			if watch.show
				return panel.questions(watch.category)

		return

	$scope.changeHeight = () ->

		# get all the topics max-height
		max = -999999

		$(".topic").each (k,o)->
			$(o).css('height', '100%'); # a hack to get actual height of object after resizing
			max = Math.max max,$(o).height()

		h =  if max < ($scope.SETTINGS.questionsCount * 50) then ($scope.SETTINGS.questionsCount * 45) + "px" else max
		$(".topic").height h
		return

	#update height when resized
	$(window).resize $scope.changeHeight


	$scope.init = () => 
		console.log $scope.topics()
		# create panels for each topic #
		for topic,cfg of $scope.topics()
			$scope.addTopic(topic)

		# update panels nodel
		$scope.panels = $scope.dashboard.get("panels")

		return

	$scope.new_data = (data,topic) ->
		$scope.$emit "Kelvi:update", {"data":data,"topic":topic}
		return this

	$scope.addNewTopic = () -> 
		topics = $scope.SETTINGS.topics

		if topics.indexOf($scope.newTopic) > -1
			#highlight row
		else
			topics.push $scope.newTopic

	$scope.removeTopic = (item) ->
		topics = $scope.SETTINGS.topics
		topics.splice topics.indexOf(item), 1
		return

	return


Kelvi.controller 'KelviConfigController',($scope,$http) ->
	
	$scope.topics = () -> GlobalConfig.topics

	$scope.addNewTopic = () ->
		updateConfig($scope.newTopic)
		$scope.newTopic = ''

	$scope.removeTopic = (topic) ->
		delete GlobalConfig.topics[topic]
		saveConfig()
		#GlobalConfig.topics.splice GlobalConfig.topics.indexOf(topic),1
		#loadConfig()

	$scope.watchesAvailable = (topic) ->
		watches = []
		for k,watch of GlobalConfig.topics[topic].watches
			if watch.enable
				watches.push(watch)
		
		return  watches

	$scope.getHttpCallsFreq = () ->
		count = 0
		freq = 0
		for topic,cfg of GlobalConfig.topics
			watchesCount = $scope.watchesAvailable(topic).length
			freq1 = watchesCount * (1000*60*60) / parseInt(GlobalConfig.topics[topic].refreshRate)		#no of http calls in 1 hr
			freq1 = freq1 / 60				# no.of calls in 1 min

			count += watchesCount
			freq += freq1

		return {'count':count,'freq':freq}
	
	$scope.config = (topic) ->
		GlobalConfig.topics[topic]

	$scope.saveConfig = () ->
		saveConfig()

	$scope.decideWatchToShow = (topic,watch) ->

		watches = $scope.watchesAvailable(topic)
		if watch.enable		#if current action is to enable watch, then do not show previously shown watch
			watches[1].show = false
		else if not watch.enable	#if current action is to disable the watch, then show next available watch
			watches[0].show = true	#show next available watch

		watch.show = watch.enable