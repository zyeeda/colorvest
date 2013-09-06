define [
    'coala/core/form/text-field'
    'coala/core/form/form-field'
    'coala/components/datetimepicker'
], (TextField, FormField) ->

    class DatePickerField extends TextField
        constructor: ->
            super
            @filterOperator = 'eq'
            @type = 'datepicker'

        getComponents: ->
            if @readOnly then [] else [type: 'datepicker', selector: @id]

    FormField.add 'datepicker', DatePickerField

    DatePickerField
