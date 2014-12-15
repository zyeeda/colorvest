Widget = require 'core/widget'
TodoListWidget = require 'widget/todo-list'

TodoList = React.createClass TodoListWidget.options

TodoWidget = new Widget
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
        <div>
            <h3 className='alert alert-info'>任务列表</h3>
            <TodoList items={@state.items} />
            <form onSubmit={@handleSubmit}>
                <input className='form-group form-control' onChange={@onChange} value={@state.text} />
                <button className='btn btn-success glyphicon-plus'>{'增加 #' + (@state.items.length + 1)}</button>
            </form>
        </div>

module.exports = React.createClass TodoWidget.options
