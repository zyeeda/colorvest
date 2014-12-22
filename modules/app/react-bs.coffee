App = require 'core/app'

Text = require 'widget/text'

class ReactBsApp extends App	

	render: ->
		# console.log ' render react bs app ...',	this
		<div className="container-fluid">

			<Text 
				id='sex' 
				text='性别' 
				name='sex' 
				color='has-warning' 
				placeholder='请填写性别'
				help = 'i need some help!'
				/>
		</div>

module.exports = ReactBsApp