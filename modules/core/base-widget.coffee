Layout = require 'colorvest/core/layout'
Region = require 'colorvest/core/region'

class BaseWidget
	
	constructor: (@options) ->
		@name = options.name
		@initLayout()
		@initRegions()
	
	getLayout: ->
		# @layout

	getParent: ->
		for region in @layout.regions
			return region if region.widget.name is @name

	find: ->

	findRegion: (name) ->
		@layout.regions[name]

	findWidget: (name) ->
		for region in @layout.regions
			return region.widget if region.widget.name is name

	initLayout: ->
		@layout = new Layout name: @options.layout, widget: @
		@layout

	initRegions: ->
		@layout.regions = []
		for region in @options.regions
			@layout.regions.push new Region
				name: region.region
				height: region.height
				content: region.content
				layout: @layout
				widget: @

module.exports = BaseWidget
