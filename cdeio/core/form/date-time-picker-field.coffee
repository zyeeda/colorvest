define [
    'cdeio/core/form/text-field'
    'cdeio/core/form/form-field'
    'cdeio/components/datetimepicker'
], (TextField, FormField) ->

    class DateTimePickerField extends TextField
        constructor: ->
            super
            @filterOperator = 'eq'
            @type = 'datetimepicker'

        getComponents: ->
            if @readOnly then [] else [type: 'datetimepicker', selector: @id]

    FormField.add 'datetimepicker', DateTimePickerField

    DateTimePickerField
