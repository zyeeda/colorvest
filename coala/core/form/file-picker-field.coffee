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
            if _.isString @options.acceptFileTypes
                @options.acceptFileTypes = new RegExp(@options.acceptFileTypes, 'i')

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
                picker = @form.findComponent('a-' + @id)
                return unless picker
                picker.loadData data

        getFormData: ->
            if @readOnly
                @value?.id 
            else
                field = @form.findComponent('a-' + @id)
                return unless field
                field.getFormData()

        getTemplateString: -> '''
            <% if (readOnly) { %>
                <div class="c-view-form-field">
                    <div class="field-label"><%= label %></div><div id="<%= id %>" class="field-value">
                        <% if (options.multiple) { %>
                        {{#each <%= name %>}}
                        <a target="_blank" href="<%= options.url %>/{{id}}">{{filename}}</a>
                        {{/each}}
                        <% } else { %>
                        <a target="_blank" href="<%= options.url %>/{{<%= name %>.id}}">{{<%= name %>.filename}}</a>
                        <% } %>
                    </div>
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
