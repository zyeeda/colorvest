class Region
	constructor: (@options) ->
		@name = options.name
		@height = options.height
		@content = options.content
		@parent = options.parent

	getParent: ->
		@parent

	getWidget: ->
		@widget

	mountWidget: (widget) ->
		@widget = widget

	unmountWidget: ->
		@widget = undefined

module.exports = Region
