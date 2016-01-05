define [
    'jquery'
    'underscore'
    'cdeio/core/form-view'
    'cdeio/core/custom-form-view'
], ($, _, FormView, CustomFormView) ->
    layout:
        regions:
            title: 'title'
            operators: 'operators'
            grid: 'body'

        extend:
            serializeData: (_super) ->
                data = _super.apply this
                data = _.extend isTheOnlyField: @feature.startupOptions.isTheOnlyField, data
                data

    views: [
        # handlers 是默认加载的。
        name: 'inline:title'
        region: 'title'
        avoidLoadingHandlers: true
        extend:
            # 为什么 views/title 中的扩展不起作用？因为 loader 不同。
            templateHelpers: ->
                title = @feature.startupOptions.label
                title: title
    ,
        name: 'inline:operators'
        region: 'operators',
        components: [ ->
            {picker, readOnly} = @feature.startupOptions
            if picker and not readOnly
                _.extend selector: 'picker', picker
        ]
        events:
            'click pick': 'showPicker'
            'click remove': 'removeItem'
            'click add': 'createItem'
            'click show': 'showItem'
            'click edit': 'updateItem'
        extend:
            fakeId: (su, id) ->
                if id then id.indexOf('FAKEID-') is 0 else _.uniqueId 'FAKEID-'

            afterRender: (su) ->
                su.apply @
                picker = @components[0]
                app = @feature.module.getApplication()
                grid = @feature.views['inline:grid'].components[0]
                if picker
                    picker.setValue = (value) ->
                        value = [value] unless _.isArray value
                        data = grid.fnGetData()

                        for v in value
                            exists = false
                            exists = true for d in data when d.id is v.id
                            grid.addRow v if not exists
                    picker.getFormData = ->
                        grid.fnGetData()

                if not @loadViewFormDeferred and (@feature.startupOptions and not @feature.startupOptions.loadViewFormDeferred)
                    @loadViewFormDeferred = $.Deferred()
                    url = app.url @feature.startupOptions.url + '/configuration/forms/show'
                    $.get(url).done (data) =>
                        def = _.extend
                            baseName: 'show'
                            module: @feature.module
                            feature: @feature
                            avoidLoadingHandlers: true
                            entityLabel: data.entityLabel
                            formName: 'show'
                        , data
                        def.form =
                            groups: data.groups or []
                            tabs: data.tabs
                        view = if def.custom then new CustomFormView def else new FormView def
                        @loadViewFormDeferred.resolve view, data.entityLabel

                if @feature.startupOptions.allowAdd
                    if not @loadAddFormDeferred
                        @loadAddFormDeferred = $.Deferred()

                        app = @feature.module.getApplication()
                        url = app.url @feature.startupOptions.url + '/configuration/forms/add'
                        $.get(url).done (data) =>
                            def = _.extend
                                baseName: 'add'
                                module: @feature.module
                                feature: @feature
                                avoidLoadingHandlers: true
                                entityLabel: data.entityLabel
                                formName: 'add'
                            , data
                            def.form =
                                groups: data.groups or []
                                tabs: data.tabs
                            view = if def.custom then new CustomFormView def else new FormView def
                            @loadAddFormDeferred.resolve view, data.entityLabel

                if @feature.startupOptions.allowEdit is true
                    if not @loadEditFormDeferred
                        @loadEditFormDeferred = $.Deferred()
                        url = app.url @feature.startupOptions.url + '/configuration/forms/edit'
                        $.get(url).done (data) =>
                            def = _.extend
                                baseName: 'edit'
                                module: @feature.module
                                feature: @feature
                                avoidLoadingHandlers: true
                                entityLabel: data.entityLabel
                                formName: 'edit'
                            , data
                            def.form =
                                groups: data.groups or []
                                tabs: data.tabs
                            view = if def.custom then new CustomFormView def else new FormView def
                            @loadEditFormDeferred.resolve view, data.entityLabel

            serializeData: (su) ->
                data = su.apply @
                data.allowPick = @feature.startupOptions.allowPick
                data.allowAdd = @feature.startupOptions.allowAdd
                data.allowEdit = @feature.startupOptions.allowEdit
                data.readOnly = @feature.startupOptions.readOnly
                data.disableShow = @feature.startupOptions.disableShow

                data
    ,
        name: 'inline:grid'
        region: 'grid'
        avoidLoadingHandlers: true
        components: [ ->
            options = @feature.startupOptions.gridOptions
            scaffold = options.form.feature.options.scaffold or {}
            columns = options.columns
            renderers = scaffold.renderers or {}

            @handlers = scaffold.handlers or {}
            @beforeShowInlineGridDialog = scaffold.beforeShowInlineGridDialog
            @afterShowInlineGridDialog = scaffold.afterShowInlineGridDialog
            @validInlineGridFormData = scaffold.validInlineGridFormData
            @afterInlineGridDialogConfirm = scaffold.afterInlineGridDialogConfirm
            @beforeShowPicker = scaffold.beforeShowPicker

            for column in columns
                column.renderer = renderers[column.renderer] if _.isString(column.renderer)

            _.extend
                type: 'grid'
                selector: 'grid'
                data: []
                fixedHeader: false
            , options
        ]
    ]

    extend:
        loadFormData: (ignore, values) ->
            grid = @views['inline:grid'].components[0]
            ids = []
            data = grid.fnGetData()

            # 保存表格打开时间的原始数据
            grid.initData = values

            grid.clear()
            for d in data or []
                ids.push d.id
            for v in values or []
                # if ($.inArray v.id, ids) is -1
                    grid.addRow v

        getFormData: ->
            grid = @views['inline:grid'].components[0]
            view = @views['inline:operators']

            data = grid.fnGetData() || []
            initData = grid.initData || []

            delDataMap = {}
            delDataIds = []

            formData = []

            for d in data
                dd = _.extend {}, d

                if dd.id and dd.id.indexOf('FAKEID-') is 0
                    delete dd.id
                formData.push dd

            for inda in initData
                if !_.findWhere(data, {id: inda.id})
                    inda['__ID__'] = inda.id
                    inda['__FORM_TYPE__'] = 'delete'
                    inda['__FORM_FLAG__'] = 'true'

                    formData.push inda

            formData
