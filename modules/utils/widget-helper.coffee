widgetHelper =

	joinClasses: (className = '', others...) ->
	    names = []
	    names.push name for name in others
	    names.push className if className isnt ''
	    names

module.exports = widgetHelper
