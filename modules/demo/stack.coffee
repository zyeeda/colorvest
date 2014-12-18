App = require 'app/stack'

app = window.app = new App
	regions: [
		{ region: 'first', height: 50, content: <div style={height: '100%', background: 'yellow'}>first</div> }
    	{ region: 'second', height: 200, content: <div style={height: '100%', background: 'blue'}>second</div> }
    	{ region: 'third', height: 150, content: <div style={height: '100%', background: 'green'}>third</div> }
    	{ region: 'four', height: 150, content: <div style={height: '100%', background: 'pink'}>four</div> }
	]
app.start()
