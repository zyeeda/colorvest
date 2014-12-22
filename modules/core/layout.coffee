class Layout
	constructor: (@options) ->
		@name = options.name
		@widget = options.widget
	
	getParent: ->
		@widget

	getRegions: ->
		@regions

module.exports = Layout
