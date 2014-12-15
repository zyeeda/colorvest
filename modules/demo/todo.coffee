App = require 'app/stack'
Todo = require 'widget/todo'

app = window.app = new App
	regions: [
		region: 'first', height: 500, content: <Todo />
	]

app.start()
