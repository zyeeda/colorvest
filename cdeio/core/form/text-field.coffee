define [
    'cdeio/core/form/form-field'
], (FormField) ->

    class TextField extends FormField
        constructor: ->
            super
            @type = 'text'

    FormField.add 'text', TextField

    TextField
