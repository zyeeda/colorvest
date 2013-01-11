define [
    'jquery'
    'underscore'
    'coala/core/view'
    'coala/core/config'
], ($, _, View, config) ->
    {getPath} = config

    result = {}

    result.templates =
        operator: _.template '''
            <div class="btn-group">
              <button id="<%= id %>" class="btn" onclick="return false;">
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
        tree: '''
            <ul style="width:100%;" id="tree" class="ztree"/>
        '''

    result.getDialogTitle = (view, type, prefix) ->
        dt = view.feature.options.scaffold?.defineDialogTitle
        if _.isFunction dt
            return dt.apply view, [view, type]
        else if _.isObject dt
            return dt[type]

        return prefix + view.options.entityLabel if view.options.entityLabel
        prefix

    result.getFormData = (view) ->
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

    result.initOperatorsVisibility = (operators) ->
        @$(o.id).hide() for o in operators when ['edit', 'del', 'show'].indexOf(o.id) isnt -1

    result.ensureOperatorsVisibility = (operators, id) ->
        (if id then @$(o.id).show() else @$(o.id).hide()) for o in operators when ['edit', 'del', 'show'].indexOf(o.id) isnt -1

    result.extendEventHandlers = (view, handlers) ->
        scaffold = view.feature.options.scaffold or {}
        eventHandlers = _.extend {}, handlers, scaffold.handlers
        _.extend view.eventHandlers, eventHandlers

    result.submitHandler = (options, viewName, title, type) ->
        view = @feature.views[viewName]
        app = @feature.module.getApplication()
        ok = ->
            result.getFormData view
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
                options.submitSuccess(type)
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

    result.generateOperatorsView = (options, module, feature, deferred) ->
        feature.request(url: options.url or 'configuration/operators').done (data) ->
            strings = []
            events = {}
            delegates = {}
            ops = []
            for name, value of data
                value = label: value if _.isString value
                value.id = name
                ops.push value
            for o in ops
                o.icon = 'icon-file' if not o.icon
                strings.push result.templates.operator o
                events['click ' + o.id] = o.id
                delegates['click ' + o.id] = 'click:' + o.id if o.publish is true
            viewOptions =
                baseName: 'operators'
                module: module
                feature: feature
                events: events
                delegates: delegates
                operators: ops
                extend:
                    renderHtml: (su, data) ->
                        template = Handlebars.compile strings.join('') or ''
                        template(data)

            view = if options.createView then options.createView(viewOptions) else new View(viewOptions)
            result.extendEventHandlers view, options.handlers
            deferred.resolve view

    result.generateGridView = (options, module, feature, deferred) ->
        feature.request(url: options.url or 'configuration/grid').done (data) ->
            data.type = 'grid'
            data.selector = 'grid'
            data.pager = 'pager'
            events = data.events or {}

            viewOptions =
                baseName: 'grid'
                module: module
                feature: feature
                components: [data]
                events: events
                extend:
                    renderHtml: (su, data) ->
                        result.templates.grid

            view = if options.createView then options.createView(viewOptions) else new View(viewOptions)
            result.extendEventHandlers view, options.handlers
            deferred.resolve view

    result.generateTreeView = (options, module, feature, deferred) ->
        feature.request(url: options.url or 'configuration/tree').done (data) ->
            data = {} if data is 'undefined'
            data.type = 'tree'
            data.selector = 'tree'
            events = data.events or {}

            viewOptions =
                baseName: 'tree'
                module: module
                feature: feature
                components: [data]
                events: events
                extend:
                    renderHtml: (su, data) ->
                        result.templates.tree

            view = if options.createView then options.createView(viewOptions) else new View(viewOptions)
            result.extendEventHandlers view, options.handlers
            deferred.resolve view


    result
