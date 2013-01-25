define [
    'coala/core/form/form-field'
    'coala/components/select'
], (FormField) ->

    class DropDownField extends FormField
        constructor: ->
            super
            @type = 'dropdown'

        getComponents: ->
            [
                selector: @id
                type: 'select'
                data: @options.source
                fieldName: @name
                readOnly: @readOnly
                initSelection: (el, fn) =>
                    val = $(el).val()
                    pickerSource = @options.source
                    return fn(pickerSource[0]) if not val
                    _(pickerSource).each (item) ->
                        fn(item) if String(item.id) == String(val)
            ]

        loadFormData: (value, data) ->
            if @readOnly then @form.findComponent(@id).loadData(data) else super

        getTemplateString: ->
            '''
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %></label>
                  <div class="controls">
                    <% if (readOnly) {%>
                        <span id="<%= id %>">{{<%= value %>}}</span>
                    <% } else { %>
                        <input type="hidden" id="<%= id %>" name="<%= name %>" value="{{appearFalse <%= value %>}}"/>
                    <% } %>
                  </div>
                </div>
            '''

    FormField.add 'dropdown', DropDownField

    DropDownField
