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
            type: @type
            url: @options.source
            title: '选择' + @options.label
            fieldName: @name
            readOnly: @readOnly
            valueField: @id
            remoteDefined: true
            statusChanger: @options.statusChanger

        getComponents: ->
            [@getComponent()]

        loadFormData: (value, data) ->
            @form.findComponent('a-' + @id).loadData data

        getFormData: ->
            data = super()
            if data and data.indexOf(',') isnt -1 then data.split(',') else data

        getTemplateString: -> '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <input type="hidden" id="<%= id %>" name="<%= name %>" value="{{appearFalse <%= value %>}}"/>
                <div id="a-<%= id %>"></div>
              </div>
            </div>
        '''

    class TreePickerField extends GridPickerField
        constructor: ->
            super
            @type = 'tree-picker'

    class ManyPickerField extends GridPickerField
        constructor: ->
            super
            @type = 'many-picker'

        getComponent: ->
            o = super()
            o.grid =
                datatype: 'local'
                colModel: @options.colModel
            o

        getFormData: ->
            @form.findComponent('a-' + @id).getFormData()


    FormField.add 'grid-picker', GridPickerField
    FormField.add 'tree-picker', TreePickerField
    FormField.add 'many-picker', ManyPickerField

    type: 'view'
    name: 'forms'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        feature.request url:'configuration/forms/' + viewName, success: (data) ->
            ###
            dialogClass: if columns is 2 then 'two-column-dialog' else 'one-column-dialog'
            ###
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
            #view.options.dialogClass = "c-form-size-#{view.options.size}" if view.options.size?
            #view.options.dialogClass = if view.getMaxColumns() is 2 then 'c-double-column-modal' else 'c-single-column-modal'
            view.eventHandlers.formStatusChanged = (e) ->
                scaffold = @feature.options.scaffold or {}
                fsc = scaffold.handlers?.formStatusChanged
                if _.isFunction fsc
                    fsc.call @, @getFormData(), $(e.target)

            deferred.resolve view
        deferred
