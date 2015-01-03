class Layout
	constructor: (@options) ->
		@name = options.name
		@parent = options.parent
	
	getParent: ->
		@parent

	getRegions: ->
		@regions

module.exports = Layout
