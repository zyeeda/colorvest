define [
    'cdeio/core/form/text-field'
    'cdeio/core/form/form-field'
    'cdeio/components/datetimepicker'
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
