StackApp = require './app/stack'
Widget = require './core/widget'

Colorvest = 
	StackApp: StackApp
	Widget: Widget

Colorvest.utils = widgetHelper: require './utils/widget-helper'

module.exports = Colorvest