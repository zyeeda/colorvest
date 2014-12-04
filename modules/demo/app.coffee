v = require 'v'
TodoList = require 'demo/list'

TodoApp = v.r.createClass
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
        v.r.createElement 'div', null, 
            v.r.createElement('div', {className: 'alert alert-info'}, '任务列表'), 
            v.r.createElement(TodoList, {items: @state.items}), 
            v.r.createElement('form', {onSubmit: @handleSubmit}
                v.r.createElement('input', {className: 'form-group form-control', onChange: @onChange, value: @state.text}), 
                v.r.createElement('button', {className: 'btn btn-success glyphicon-plus'}, ' 增加 (' + (@state.items.length + 1) + ')')
            )
            
v.r.render v.r.createElement(TodoApp, null), v.$('#demo')[0] 