define [
    'coala/core/form/form-field'
], (FormField) ->

    class PlaceholderField extends FormField
        constructor: (@form, @group, @options) ->
            super @form, @group, @options
            @type = 'placeholder'
            @readOnly = true

    FormField.add 'placeholder', PlaceholderField

    PlaceholderField
