Widget = require 'core/widget'

class App extends Widget
	start: ->
		React.render @render(), document.body

module.exports = App
