define [
    'jquery'
    'cdeio/core/form/form-field'
    'cdeio/components/select'
], ($, FormField) ->

    class DropDownField extends FormField
        constructor: ->
            super
            @filterOperator = 'eq'
            @type = 'dropdown'

        getComponents: ->
            config = 
                selector: @id
                type: 'select'
                fieldName: @name
                name: @name
                readOnly: @readOnly
                multiple: @multiple
                change: @options.change

            if @options.url
                textKey = @options.textKey or 'name'
                me = this
                $.ajax(me.options.url, dataType: 'json').done (data) ->
                    config.query = (q) ->
                        t = q.term
                        result = []
                        for d in data.results
                            text = if d.text then d.text else d[textKey]
                            if text.indexOf(t) >= 0
                                result.push id: d.id, text: text
                        q.callback(results: result)
                    config.initSelection= (e, fn) ->
                        val = $(e).val()
                        results = data.results
                        # return fn(results[0]) if not val
                        _(results).each (item) ->
                            fn(item) if String(item.id) == String(val)  
                
            else
                config.data = @options.source
                config.initSelection = (el, fn) =>
                    val = $(el).val()
                    pickerSource = @options.source
                    return fn(pickerSource[0]) if not val
                    _(pickerSource).each (item) ->
                        fn(item) if String(item.id) == String(val)
            [config]

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
                    <% if (!hideLabel) { %>
                    <div class="field-label"><%= label %></div>
                    <% } %>
                    <div id="<%= id %>" class="field-value">{{<%= name %>}}</div>
                </div>
            <% } else { %>
                <div class="control-group">
                    <% if (!hideLabel) { %>
                    <label class="control-label" for="<%= id %>"><%= label %><% if (required) { %>
                        <span class="required-mark">*</span>
                    <% } %></label><% } %>
                    <div class="controls">
                        <input type="hidden" id="<%= id %>" name="<%= name %>" value="{{appearFalse <%= value %>}}"/>
                      </div>
                </div>
            <% } %>
            '''

    FormField.add 'dropdown', DropDownField

    DropDownField
