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
            [@getComponent()]

        loadFormData: (value, data) ->
            @form.findComponent('a-' + @id).loadData data

        getFormData: ->
            @form.findComponent('a-' + @id).getFormData()

        getTemplateString: -> '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <div id="a-<%= id %>"></div>
              </div>
            </div>
        '''

    FormField.add 'file-picker', FilePickerField
