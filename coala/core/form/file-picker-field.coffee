define [
    'underscore'
    'jquery'
    'coala/core/form-view'
    'coala/core/form/form-field'
], (_, $, FormView, FormField) ->
    class FilePickerField extends FormField
        constructor: ->
            super
            @type = 'file-picker'

        getComponent: ->
            _.extend
                title: '选择' + @options.label
            , @options,
                selector: 'a-' + @id
                id: 'a-' + @id
                type: @type
                name: @name
                readOnly: @readOnly

        getComponents: ->
            if @readOnly then [] else [@getComponent()]

        loadFormData: (value, data) ->
            if @readOnly
                @form.$(@id).text(value?.name)
                @value = value
            else
                @form.findComponent('a-' + @id).loadData data

        getFormData: ->
            if @readOnly then @value?.id else @form.findComponent('a-' + @id).getFormData()

        getTemplateString: -> '''
            <% if (readOnly) { %>
                <div class="c-view-form-field">
                    <div class="field-label"><%= label %></div><div id="<%= id %>" class="field-value">{{<%= value %>}}</div>
                </div>
            <% } else { %>
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %><% if (required) { %>
                        <span class="required-mark">*</span>
                    <% } %></label>
                  <div class="controls">
                    <div id="a-<%= id %>"></div>
                  </div>
                </div>
            <% } %>
        '''

    FormField.add 'file-picker', FilePickerField
