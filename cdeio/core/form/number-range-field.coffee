define [
    'cdeio/core/form/text-field'
    'cdeio/core/form/form-field'
], (TextField, FormField) ->

    class NumberRangeField extends TextField
        constructor: ->
            super
            @type = 'number-range'

        getTemplateString: -> '''
            <div class="control-group c-<%= type %>">
              <% if (!hideLabel) { %>
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <% } %>
              <div class="controls">
                <input type="text" class="input span5" id="<%= id %>-1"/> - <input type="text" class="input span5" id="<%= id %>-2"/>
              </div>
            </div>
        '''

        loadFormData: (value, data) ->
            if value == null or value == undefined
                @form.$(@id + '-1').val('')
                @form.$(@id + '-2').val('')
            else
                @form.$(@id + '-1').val(value.min)
                @form.$(@id + '-2').val(value.max)

        getFormData: ->
            min = parseInt @form.$(@id + '-1').val()
            max = parseInt @form.$(@id + '-2').val()
            return null unless min is 0 or min or max is 0 or max
            result = {}
            result.max = max + '' if max is 0 or max
            result.min = min + '' if min is 0 or min
            result

        getFilter: ->
            value = @getFormData()
            return null unless value
            if value.min and value.max
                ['between', @name, value.min, value.max]
            else if value.min and not value.max
                ['ge', @name, value.min]
            else if value.max and not value.min
                ['le', @name, value.max]

    FormField.add 'number-range', NumberRangeField

    NumberRangeField
