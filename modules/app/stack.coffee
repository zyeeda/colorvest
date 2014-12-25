App = require '../core/app'

class StackApp extends App

	mapRegions: (item) ->
		<div id={item.region} style={height: item.height} className="col-xs-12">{item.content}</div>

	render: ->
		<div className="container-fluid">
			<div className="row">
				{@options.regions.map @mapRegions}				
			</div>
		</div>

module.exports = StackApp