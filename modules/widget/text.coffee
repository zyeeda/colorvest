Widget = require 'core/widget'

joinClasses = (className = '', others...) ->
    names = []
    names.push className if className isnt ''
    names.push name for name in others
    names.join ' '

Text = React.createClass
    onBlur: (e) ->
    renderHelp: ->
        (
            <span className="help-block" key="help">
                {@props.help}
            </span>
        ) if @props.help?

    render: ->
        <div className={joinClasses 'form-group', @props.color}>
            <label className="control-label">{this.props.text}</label>
            <input type="text" 
                ref="input" 
                key="input" 
                readOnly = {'readonly' if @props.readonly is 'readonly'} 
                className = {joinClasses 'form-control'} 
                placeholder = {@props.placeholder}  
                />
            {@renderHelp()}
        </div>

module.exports = Text
