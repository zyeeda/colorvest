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
        <div>
            <h3 className='alert alert-info'>任务列表</h3>
            <TodoList items={this.state.items} />
            <form onSubmit={this.handleSubmit}>
                <input className='form-group form-control' onChange={this.onChange} value={this.state.text} />
                <button className='btn btn-success glyphicon-plus'>{'增加 #' + (this.state.items.length + 1)}</button>
            </form>
        </div>

module.exports = TodoApp
