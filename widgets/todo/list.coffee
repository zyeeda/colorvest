createItem = (itemText) ->
	<li className="list-group-item">{itemText}</li>
			
TodoList = React.createClass
	render: ->
		<ul className="list-group">{this.props.items.map(createItem)}</ul>

module.exports = TodoList

