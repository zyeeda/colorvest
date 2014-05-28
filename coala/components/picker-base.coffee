define [
    'underscore'
    'jquery'
    'coala/coala'
    'coala/core/view'
    'coala/core/form-view'
    'handlebars'
], (_, $, coala, View, FormView, H) ->

    class PickerChooser
        constructor: (@picker) ->
            @feature = picker.view.feature
            @module = @feature.module
            @app = @module.getApplication()
            @view = @generateView()
            @view.eventHandlers = @getViewHandlers()

        generateView: ->
            tpl = H.compile @getViewTemplate()
            
            pickerFiled = @picker.name or ''
            feature = @feature
            pickerFeatureName = feature.baseName
            pickerFeatureType = 'feature'
            if feature.baseName is 'inline-grid'
                pickerFeatureName = feature.startupOptions.gridOptions.form.feature.baseName
                pickerFeatureType = 'inline-grid'

            options =
                feature: @feature
                module: @module
                baseName: 'picker-chooser'
                model: @picker.options.url + '/picker?pickerFeatureName=' + pickerFeatureName + '&pickerFeatureType=' + pickerFeatureType + '&pickerFiled=' + pickerFiled
                components: @getViewComponents()
                events: @getViewEvents()
                avoidLoadingHandlers: true
                extend:
                    renderHtml: (su, data) ->
                        tpl data

            @verifyViewOptions options

            new View options

        getViewTemplate: ->
            '<table id="grid"></table>'

        getViewComponents: ->
            grid = _.extend {}, @picker.options.grid,
                type: 'grid'
                selector: 'grid'
                deferLoading: 0
            ,
                if @picker.options.multiple is true then multiple: true else {}
                if @picker.options.crossPage is true then crossPage: true else {}

            [grid]

        getViewEvents: -> {}
        getViewHandlers: -> {}

        verifyViewOptions: (options) ->

        getSelectedItems: ->
            grid = @view.components[0]
            selected = grid.getSelected()
            return false unless selected

            selected = [selected] unless @picker.options.multiple is true

            items = []
            for model in selected
                items.push model.toJSON()
            items

        show: ->
            feature = @view.feature
            pickerFeatureType = 'feature'

            if feature.baseName is 'inline-grid'
                feature = feature.startupOptions.gridOptions.form.feature
                pickerFeatureType = 'inline-grid'

            pickerFiled = @picker.name or ''
            pickerFeatureName = feature.baseName

            scaffold = feature.options.scaffold or {}
            handlers = scaffold.handlers or {}

            beforeShowPicker = handlers[@picker.beforeShowPicker]
            if _.isFunction beforeShowPicker
                return unless (beforeShowPicker.call @, @view, pickerFiled, pickerFeatureType, pickerFeatureName) is true

            @app.showDialog
                title: @picker.options.title
                view: @view
                buttons: [
                    label: @picker.options.buttonLabel or '确定'
                    status: 'btn-primary'
                    fn: =>
                        selected = @getSelectedItems()
                        if not selected
                            @app.error '请选择记录'
                            return false

                        selected = selected[0] if not @picker.options.multiple

                        feature = @view.feature
                        featureType = 'feature'
                        if feature.baseName is 'inline-grid'
                            feature = feature.startupOptions.gridOptions.form.feature
                            featureType = 'inline-grid'

                            scaffold = feature.options.scaffold or {}
                            handlers = scaffold.handlers or {}

                            beforePickerConfirm = handlers[@picker.beforePickerConfirm]
                            if _.isFunction beforePickerConfirm
                                return false if (beforePickerConfirm.call @, @view, selected, featureType) is false

                            callback = handlers[@picker.callback]
                            if (_.isFunction callback) is true
                                callback.call @, @view, selected, featureType
                        else
                            scaffold = feature.options.scaffold or {}
                            handlers = scaffold.handlers or {}

                            beforePickerConfirm = handlers[@picker.beforePickerConfirm]
                            if _.isFunction beforePickerConfirm
                                return false if (beforePickerConfirm.call @, @view, selected, featureType) is false

                        @picker.setValue selected
                ]
                onClose: ->
                    @view.findComponent('grid')?.unbind 'draw'
            .done =>
                form = @picker.options.form
                grid = @view.findComponent('grid')
                return if not grid
                if form
                    data = form.getFormData()
                    grid.addParam 'data', data

                selected = @picker.getFormData() or []
                grid.on 'draw', ->
                    grid.find('#chk-' + d.id).prop('checked', true).prop('disabled', true) for d in selected
                grid.refresh()

    class Picker
        constructor: (@options = {}) ->
            @id = options.id or _.uniqueId 'picker'
            @name = options.name
            @value = options.value
            @text = options.text or @value
            @container = options.container
            @view = options.view
            @triggerClass = options.triggerClass
            @allowAdd = options.allowAdd

            # after confirm picker's function
            #
            @callback = options.callback

            # before show picker dialog's function
            #
            @beforeShowPicker = options.beforeShowPicker

            # before picker confirm function return's function
            #
            @beforePickerConfirm = options.beforePickerConfirm

            # allow init picker filed's data after show dialog
            # * if one form has two or more picker, after show dialog then will call picker's setValue function twice or more, this will cause formData structure error
            # * if one form has only one picker, but has special requirement
            # for example(Object{a: 'a', b: Object{b1: 'b1', b2: 'b2'}} will be changed to Object{a: 'a', 'b.b1': 'b1', 'b.b2': 'b2'})
            #
            @allowInitPickerFieldData = options.allowInitPickerFieldData

            if options.chooser
                @chooser = options.chooser
            else
                Type = options.chooserType or PickerChooser
                @chooser = new Type @

            if @allowAdd
                feature = @view.feature
                app = feature.module.getApplication()
                url = app.url "#{options.url}/configuration/forms/add"

                @addFormDeferred = $.Deferred()
                $.get(url).done (data) =>
                    def = _.extend
                        baseName: 'add'
                        module: feature.module
                        feature: feature
                        avoidLoadingHandlers: true
                        entityLabel: data.entityLabel
                        formName: 'add'
                    , data
                    def.form =
                        groups: data.groups or []
                        tabs: data.tabs

                    view = new FormView def
                    @addFormDeferred.resolve view, data.entityLabel

        getFormData: ->
            id = @options.toValue or (data) -> data.id
            if _.isArray @value
                (id item for item in @value)
            else
                id @value or {}

        setText: (text) ->
            @text = text
            if @renderred is true
                @container.find('#text-' + @id).html text

        setValue: (value) ->
            _this = @
            feature = @options.view.feature
            featureType = 'feature'

            if feature.baseName is 'inline-grid'
                feature = @options.view.feature.startupOptions.gridOptions.form.feature
                featureType = 'inline-grid'

            scaffold = feature.options.scaffold or {}
            handlers = scaffold.handlers or {}
            callback = handlers[@callback]

            text = @options.toText or (data) -> if data then data.name else ''
            if _.isArray value
                t = (text item for item in value).join ','
            else
                t = text value
            @setText t
            @value = value

            if @options.form and @options.extraFields and value
                data = {}
                data[target] = value[field] for field,target of @options.extraFields

                # if picker has callback function, then set name value first, then call callback, or set name value dircetly
                #
                if (_.isFunction callback) is true
                    @options.form.setFormData data, true
                    callback.call _this, _this.options.view, value, featureType
                else
                    @options.form.setFormData data, true

        loadData: (data) ->
            # allow init picker filed's data after show dialog
            # * if one form has two or more picker, after show dialog then will call picker's setValue function twice or more, this will cause formData structure error
            # * if one form has only one picker, but has special requirement
            # for example(Object{a: 'a', b: Object{b1: 'b1', b2: 'b2'}} will be changed to Object{a: 'a', 'b.b1': 'b1', 'b.b2': 'b2'})
            #
            if @allowInitPickerFieldData isnt false || @view.baseName is 'add'
                @setValue if @name then data[@name] else data

        getTemplate: -> _.template '''
            <div class="c-picker">
                <span class="uneditable-input"><span class="text" id="text-<%= id %>"><%= text %></span>
                    <% if (allowAdd) { %><a id="add-<%= id %>" class="btn pull-right plus <%= triggerClass %>"><i class="icon-plus"/></a><% } %>
                    <a id="trigger-<%= id %>" class="btn pull-right <%= triggerClass %>"><i class="icon-search"/></a>
                </span>
            </div>
            '''
        showAddForm: ->
            return if not @addFormDeferred
            @addFormDeferred.done (form, title) =>
                app = @options.view.feature.module.getApplication()
                url = app.url(@options.url)

                app.showDialog
                    title: '新增' + title
                    view: form
                    buttons: [
                        label: '确定'
                        status: 'btn-primary'
                        fn: =>
                            return false unless form.isValid()
                            data = form.getFormData()
                            $.post(url, data).done (data) =>
                                form.reset()
                                @setValue data
                    ]


        render: ->
            return if @renderred
            @renderred = true

            @container.html @getTemplate() @
            @container.find('#trigger-' + @id).click =>
                @chooser.show(@)
            @container.find('#add-' + @id).click =>
                @showAddForm()

    Picker: Picker
    Chooser: PickerChooser
