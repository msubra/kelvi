class Panel
	constructor: (@name,@settings) ->
		@id = "_pnl_#{@name}"

	init: () ->

	update: () ->

class Dashboard
	panelContainer = {} # collection of Panel instances

	constructor: (@name) ->

	_addNewPanel: (name,settings) ->
		newPanel = new Panel(name,settings)
		panelContainer[name] = {"panel":newPanel,"settings":settings or null}

	createPanel: (name,settings) ->
		this._addNewPanel name,settings

	addPanel: (panel) ->	#panel object here
		panelContainer[panel.name] = panel

	getPanel: (name) ->
		panelContainer[name] or null

	get: (name) ->
		if name is "panels"
			panels = []
			for name,o of panelContainer
				panels.push(o)

			return panels

		return null
