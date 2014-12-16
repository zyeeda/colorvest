App = require 'app/stack'
Todo = require 'widget/todo'

hello = ->
	console.log 'hello colorvest'

app = window.app = new App
	regions: [
		region: 'first', height: 500, content: <Todo />
	]

	routes:
        "help":                 "help"
        "search/:query":        "search"
        "search/:query/p:page": "search"
        "hello":                hello

    help: ->
        console.log 'help'

    search: (query, page) ->
        console.log query, page

app.route 'test', ->
	console.log 'hello test'

app.start()
