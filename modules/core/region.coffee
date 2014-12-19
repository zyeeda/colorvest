class Region
	constructor: (@options) ->
		@name = options.name
		@height = options.height
		@content = options.content
		@layout = options.layout
		@widget = options.widget

	getParent: ->
		@layout

	getWidget: ->
		@widget

module.exports = Region
