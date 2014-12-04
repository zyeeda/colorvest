createItem = (itemText) ->
	<li class="list-group-item">{itemText}</li>
			
TodoList = React.createClass 
    displayName: 'TodoList'
    render: ->
        <ul class="list-group">{this.props.items.map(createItem)}</ul>

module.exports = TodoList
