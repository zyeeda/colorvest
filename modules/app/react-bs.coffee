App = require 'colorvest/core/app'

Text = require 'colorvest/widget/text'

class ReactBsApp extends App	

	render: ->
		# console.log ' render react bs app ...',	this
		<div className="container-fluid">
			<Text 
				id='name' 
				text='姓名' 
				name='name' 
				color='has-success' 
				placeholder='请填写姓名'
				defaultValue='123'
				help = 'i need some help!'
				/>
			<Text 
				id='name' 
				text='性别' 
				name='sex' 
				color='has-warning' 
				placeholder='请填写性别'
				help = 'i need some help!'
				/>
		</div>

module.exports = ReactBsApp