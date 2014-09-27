define [
    'cdeio/core/form/form-field'
    'cdeio/core/form/number-range-field'
], (FormField, NumberRangeField) ->

    class DateRangeField extends NumberRangeField
        constructor: ->
            super
            @type = 'date-range'

        getComponents: -> [
            type: 'datepicker', selector: @id + '-1'
        ,
            type: 'datepicker', selector: @id + '-2'
        ]

        getFormData: ->
            min = @form.$(@id + '-1').val()
            max = @form.$(@id + '-2').val()
            return null unless min or max
            result = {}
            result.max = max if max
            result.min = min if min
            result

    FormField.add 'date-range', DateRangeField

    DateRangeField
