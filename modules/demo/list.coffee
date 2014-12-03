TodoList = v.r.createClass 
    displayName: 'TodoList'
    render: ->
        createItem = (itemText) ->
            v.r.createElement 'li', {className: 'list-group-item'}, itemText
        v.r.createElement 'ul', {className: 'list-group'}, @props.items.map createItem

module.exports = TodoList
