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
            o.pickerGrid =
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
            view.options.size or= 'large'
            view.options.dialogClass = "c-form-size-#{view.options.size}"
            view.eventHandlers.formStatusChanged = (e) ->
                scaffold = @feature.options.scaffold or {}
                fsc = scaffold.handlers?.formStatusChanged
                if _.isFunction fsc
                    fsc.call @, @getFormData(), $(e.target)

            deferred.resolve view
        deferred
