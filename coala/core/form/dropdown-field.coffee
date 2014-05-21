define [
    'coala/core/form/form-field'
    'coala/components/select'
], (FormField) ->

    class DropDownField extends FormField
        constructor: ->
            super
            @filterOperator = 'eq'
            @type = 'dropdown'

        getComponents: ->
            [
                selector: @id
                type: 'select'
                data: @options.source
                fieldName: @name
                name: @name
                readOnly: @readOnly
                initSelection: (el, fn) =>
                    val = $(el).val()
                    pickerSource = @options.source
                    return fn(pickerSource[0]) if not val
                    _(pickerSource).each (item) ->
                        fn(item) if String(item.id) == String(val)
            ]

        afterRender: ->
            if @options.defaultValue
                select = @form.findComponent(@id)
                select.select2?('val', @options.defaultValue)

        loadFormData: (value, data) ->
            select = @form.findComponent(@id)
            return unless select
            if @readOnly
                select.loadData(data)
            else
                if value?
                    super
                    _.defer -> select.select2('val', value + '')
                else
                    select.select2('val', @options.defaultValue or '')

        getTemplateString: -> '''
            <% if (readOnly) {%>
                <div class="c-view-form-field">
                    <div class="field-label"><%= label %></div><div id="<%= id %>" class="field-value">{{<%= name %>}}</div>
                </div>
            <% } else { %>
                <div class="control-group">
                    <label class="control-label" for="<%= id %>"><%= label %><% if (required) { %>
                        <span class="required-mark">*</span>
                    <% } %></label>
                    <div class="controls">
                        <input type="hidden" id="<%= id %>" name="<%= name %>" value="{{appearFalse <%= value %>}}"/>
                      </div>
                </div>
            <% } %>
            '''

    FormField.add 'dropdown', DropDownField

    DropDownField
