define [
    'cdeio/core/form/form-field'
], (FormField) ->

    class HiddenField extends FormField
        constructor: ->
            super
            @type = 'hidden'

        getTemplateString: ->
            '<input id="<%= id %>" type="hidden" name="<%= name %>" value="{{<%= value %>}}"/>'

    FormField.add 'hidden', HiddenField

    HiddenField
