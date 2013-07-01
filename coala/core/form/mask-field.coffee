define [
    'coala/core/form/form-field'
    'underscore'
    'coala/components/masked-input'
], (FormField, _) ->

    class MaskField extends FormField
        constructor: ->
            super
            @type = 'text'
        getComponents: ->
            return [] if @readOnly
            [_.extend {}, @options, type: 'mask', selector: @id]

    FormField.add 'mask', MaskField

    MaskField
