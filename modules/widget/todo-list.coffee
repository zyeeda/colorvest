Widget = require 'core/widget'

createItem = (itemText) ->
	<li className="list-group-item">{itemText}</li>
			
TodoList = new Widget
	render: ->
		<ul className="list-group">{this.props.items.map(createItem)}</ul>

module.exports = TodoList

