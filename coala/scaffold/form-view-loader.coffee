define [
    'coala/core/view'
    'handlebars'
    'underscore'
    'jquery'
    'coala/core/form-view'
    'coala/core/form/form-field'
], (View, Handlebars, _, $, FormView, FormField) ->

    class GridPickerField extends FormField
        constructor: ->
            super
            @type = 'grid-picker'

        getComponent: ->
            selector: 'a-' + @id
            id: 'a-' + @id
            type: @type
            url: @options.source
            title: '选择' + @options.label
            name: @name
            readOnly: @readOnly
            remoteDefined: true
            statusChanger: @options.statusChanger

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

    class TreePickerField extends GridPickerField
        constructor: ->
            super
            @type = 'tree-picker'

    class MultiGridPickerField extends GridPickerField
        constructor: ->
            super
            @type = 'multi-grid-picker'

        getComponent: ->
            o = super()
            o.pickerGrid =
                datatype: 'local'
                colModel: @options.colModel
            o

    class MultiTreePickerField extends MultiGridPickerField
        constructor: ->
            super
            @type = 'multi-tree-picker'

    FormField.add 'grid-picker', GridPickerField
    FormField.add 'tree-picker', TreePickerField
    FormField.add 'multi-grid-picker', MultiGridPickerField
    FormField.add 'multi-tree-picker', MultiTreePickerField

    type: 'view'
    name: 'form'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        feature.request url:'configuration/forms/' + viewName, success: (data) ->
            def = _.extend
                baseName: viewName
                module: module
                feature: feature
                avoidLoadingHandlers: true
                entityLabel: data.entityLabel
                formName: viewName
            , data
            def.form =
                groups: data.groups
                tabs: data.tabs

            view = new FormView def
            view.eventHandlers.formStatusChanged = (e) ->
                scaffold = @feature.options.scaffold or {}
                fsc = scaffold.handlers?.formStatusChanged
                if _.isFunction fsc
                    fsc.call @, @getFormData(), $(e.target)

            deferred.resolve view

        deferred.promise()
