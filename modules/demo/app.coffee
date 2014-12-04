v = require 'v'
TodoList = require 'demo/list'

TodoApp = React.createClass
    displayName: 'TodoApp'
    getInitialState: ->
        items: [], text: ''

    onChange: (e) ->
        @setState text: e.target.value
    
    handleSubmit: (e) ->
        e.preventDefault()
        nextItems = @state.items.concat [@state.text]
        nextText = ''
        @setState items: nextItems, text: nextText

    render: ->
        React.createElement 'div', null, 
            React.createElement('div', {className: 'alert alert-info'}, '任务列表'), 
            React.createElement(TodoList, {items: @state.items}), 
            React.createElement('form', {onSubmit: @handleSubmit}
                React.createElement('input', {className: 'form-group form-control', onChange: @onChange, value: @state.text}), 
                React.createElement('button', {className: 'btn btn-success glyphicon-plus'}, ' 增加 (' + (@state.items.length + 1) + ')')
            )
            
React.render React.createElement(TodoApp, null), $('#demo')[0] 