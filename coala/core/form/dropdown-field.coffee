define [
    'jquery'
    'coala/core/form/form-field'
    'coala/components/select'
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
            if @options.url
                textKey = @options.textKey or 'name'
                config.ajax =
                    url: @options.url,
                    dataType: 'json',
                    data: (term, page) ->
                        q: term
                    results: (data, page) ->
                        (d.text = d[textKey] if not d.text) for d in data.results
                        results: data.results

                config.initSelection = (el, fn) =>
                    val = $(el).val()
                    if val != ''
                        $.ajax(@options.url, dataType: 'json').done (data) ->
                            _(data.results).each (item) ->
                                (d.text = d[textKey] if not d.text) for d in data.results
                                return fn(data.results[0]) if not val
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
