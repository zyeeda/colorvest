define [
    'cdeio/core/view'
    'handlebars'
    'underscore'
    'jquery'
    'cdeio/core/form-view'
    'cdeio/core/custom-form-view'
    'cdeio/core/form/form-field'
], (View, Handlebars, _, $, FormView, CustomFormView, FormField) ->

    class GridPickerField extends FormField
        constructor: ->
            super
            @filterOperator = 'eq'
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
            allowAdd: !!@options.allowAdd
            extraFields: @options.extraFields or []
            form: @form
            multiple: !!@options.multiple
            textKey: @options.textKey

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
                picker = @form.findComponent('a-' + @id)
                return unless picker
                picker.getFormData()

        getTemplateString: -> '''
            <% if (readOnly) { %>
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
        feature.request url:'configuration/forms/' + viewName, success: (data = {groups: []}) ->
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
            if def.custom
                view = new CustomFormView def
            else
                view = new FormView def
            view.eventHandlers.formStatusChanged = (e) ->
                scaffold = @feature.options.scaffold or {}
                fsc = scaffold.handlers?.formStatusChanged
                if _.isFunction fsc
                    fsc.call @, @getFormData(), $(e.target)

            deferred.resolve view

        deferred.promise()
