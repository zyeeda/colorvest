StackApp = require './app/stack'
Widget = require './core/widget'

Colorvest = 
	StackApp: StackApp
	Widget: Widget


Colorvest.utils = 
	widgetUtil: require './utils/widget-util'

module.exports = Colorvest
