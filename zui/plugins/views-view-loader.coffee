define [
    'jquery'
    'underscore'
    'zui/coala/view'
    'zui/coala/config'
    'zui/coala/loader-plugin-manager'
], ($, _, View, config, LoaderManager) ->
    {getPath} = config

    templates =
        operator: _.template '''
            <div class="btn-group">
              <button id="<%= id %>" class="btn">
                <% if (icon) { %>
                    <i class="<%= icon %>"/>&nbsp;
                <% } %>
                <%= label %></button>
            </div>
        '''
        grid: '''
            <table style="width:100%;" id="grid"/>
            <div id="pager"/>
        '''

    getFormData = (view) ->
        values = view.$$('form').serializeArray()
        data = {}
        _(values).map (item) ->
            if item.name of data
                data[item.name] = if _.isArray(data[item.name]) then data[item.name].concat([item.value]) else [data[item.name], item.value]
            else
                data[item.name] = item.value
        view.model.set data
        _(view.components).each (component) ->
            if _.isFunction(component.getFormData)
                d = component.getFormData()
                view.model.set d.name, d.value if d


    submitHandler = (viewName, title) ->
        view = @feature.views[viewName]
        app = @feature.module.getApplication()
        ok = ->
            getFormData view
            validator = view.$$('form').valid()
            return false if !validator
            $.when(view.model.save()).then (data) ->
                if data.violations
                    msg = ''
                    summary = ''
                    labels = view.forms.fields
                    for err in data.violations
                        unless err.properties
                            summary += err.message + '\n'
                        for label in labels
                            if label.name == err.properties
                                msg += "#{[label.label]} #{err.message}\n"
                    msg += summary
                    app.error msg, '验证提示'
                    return
                view.feature.views['views:grid'].components[0].trigger('reloadGrid')
                app.success '操作成功'
                app._modalDialog.modal.modal 'hide'
            , ->
                app.error '系统出错！'
            false

        app.showDialog(
            view: view
            title: title
            buttons: [label: 'Ok', fn: ok]
        ).done (dialog) ->
            v = dialog.startupOptions.view
            data = v.model.toJSON()
            _(v.components).each (component) ->
                component.loadData data if _.isFunction(component.loadData)
        .done ->
            return unless view.forms.validator
            result = view.forms.validator
            view.$$('form').validate({
                rules: view.forms.validator.rules,
                messages: view.forms.validator.messages,
                highlight: (label) ->
                    $(label).closest('.control-group').removeClass('success')
                    $(label).closest('.control-group').addClass('error')
                ,
                success: (label) ->
                    $(label).text('OK!').addClass('valid').closest('.control-group').removeClass('error')
                    $(label).text('OK!').addClass('valid').closest('.control-group').addClass('success')
            })

    handlers =
        add: ->
            @feature.views['forms:add'].model.clear()
            submitHandler.call @, 'forms:add', 'Create New Item'
        edit: ->
            grid = @feature.views['views:grid'].components[0]
            view = @feature.views['forms:edit']
            app = @feature.module.getApplication()
            selected = grid.getGridParam('selrow')
            return app.info '请选择要操作的记录' if not selected

            view.model.set 'id', selected
            $.when(view.model.fetch()).then =>
                submitHandler.call @, 'forms:edit', 'Edit Item'
        del: ->
            grid = @feature.views['views:grid'].components[0]
            selected = grid.getGridParam('selrow')
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            @feature.model.set 'id', selected
            $.when(@feature.model.destroy()).then (data) =>
                if data.violations
                    msg = ''; summary = ''
                    for err in data.violations
                        unless err.properties
                            summary += err.message + '\n'
                    msg += summary
                    app.error msg, '验证提示'
                    return
            grid.trigger 'reloadGrid'
        show: ->
            grid = @feature.views['views:grid'].components[0]
            view = @feature.views['forms:edit']
            selected = grid.getGridParam('selrow')
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            view.model.set 'id', selected
            $.when(view.model.fetch()).then ->
                app.showDialog(
                    view: view
                    title: 'View Item'
                    buttons: []
                ).done ->
                    view.$$('form input').attr('readonly', true)
        refresh: ->
            grid = @feature.views['views:grid'].components[0]
            grid.trigger('reloadGrid')

    initOperatorsVisibility = (operators) ->
        @$(o.id).hide() for o in operators when ['edit', 'del', 'show'].indexOf(o.id) isnt -1

    ensureOperatorsVisibility = (operators, id) ->
        (if id then @$(o.id).show() else @$(o.id).hide()) for o in operators when ['edit', 'del', 'show'].indexOf(o.id) isnt -1

    generateOperatorsView = (module, feature, deferred) ->
        scaffold = feature.options.scaffold or {}
        eventHandlers = _.extend {}, handlers, scaffold.handlers

        feature.request url:'configuration/operators', success: (data) ->
            strings = []
            events = {}
            ops = []
            for name, value of data
                value = label: value if _.isString value
                value.id = name
                ops.push value
            for o in ops
                o.icon = 'icon-file' if not o.icon
                strings.push templates.operator o
                events['click ' + o.id] = o.id
            view = new View
                baseName: 'operators'
                module: module
                feature: feature
                events: events
                operators: ops
                extend:
                    renderHtml: (su, data) ->
                        template = Handlebars.compile strings.join('') or ''
                        template(data)
            _.extend view.eventHandlers, eventHandlers
            deferred.resolve view

    generateGridView = (module, feature, deferred) ->
        scaffold = feature.options.scaffold or {}
        eventHandlers = scaffold.handlers
        visibility = scaffold.ensureOperatorsVisibility or ensureOperatorsVisibility
        initVisibility = scaffold.initOperatorsVisibility or initOperatorsVisibility

        feature.request url:'configuration/grid', success: (data) ->
            data.type = 'grid'
            data.selector = 'grid'
            data.pager = 'pager'
            data.onSelectRow = 'selectionChanged'
            data.beforeRequest = 'refresh'
            events = data.events or {}

            view = new View
                baseName: 'grid'
                module: module
                feature: feature
                components: [data]
                events: events
                extend:
                    renderHtml: (su, data) ->
                        templates.grid
            view.eventHandlers ?= {}
            _.extend view.eventHandlers, eventHandlers
            view.eventHandlers.selectionChanged = (id, status) ->
                return if not status
                v = @feature.views['views:operators']
                visibility.call v, v.options.operators, id
            view.eventHandlers.refresh = ->
                v = @feature.views['views:operators']
                initVisibility.call v, v.options.operators
            deferred.resolve view

    type: 'view'
    name: 'views'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        if viewName is 'operators'
            generateOperatorsView(module, feature, deferred)
        else if viewName is 'grid'
            generateGridView(module, feature, deferred)

        deferred
