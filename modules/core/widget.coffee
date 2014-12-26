BaseWidget = require './base-widget'

class Widget extends BaseWidget

	mountWidget: (widget, regionName) ->
		region = @findRegion regionName
		region.mountWidget widget

	unmountWidget: (layout) ->
		region = @findRegion regionName
		region.unmountWidget()

	activeRegion: (regionName) ->
		# :TODO

	render: ->
		#: TODO

module.exports = Widget
