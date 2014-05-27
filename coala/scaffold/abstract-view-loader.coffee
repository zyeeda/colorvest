define [
    'jquery'
    'underscore'
    'coala/core/view'
    'coala/core/config'
], ($, _, View, config) ->
    {getPath} = config

    result = {}
    permMap = refresh: 'show'
    getPermissionId = (id) ->
        if permMap[id] then permMap[id] else id

    result.templates =
        buttonGroup: _.template '''
            <div class="btn-group">
                <%= buttons %>
            </div>
        '''

        operator: _.template '''
            <button id="<%= id %>" class="btn <% if (style) { %> <%=style%> <% } %>" onclick="return false;" style="display:none;">
                <% if (icon) { %>
                <i class="<%= icon %> <% if (!label) { %>icon-only<% } %>" />
                <% } %>

                <% if (label) { %>
                <%= label %>
                <% } %>
            </button>
        '''

        grid: '''
            <table style="width:100%;" id="grid" />
        '''

        tree: '''
            <ul id="tree" class="ztree"/>
        '''

    result.getDialogTitle = (view, type, prefix) ->
        dt = view.feature.options.scaffold?.defineDialogTitle
        if _.isFunction dt
            return dt.apply view, [view, type]
        else if _.isObject dt
            return dt[type]

        return prefix + view.options.entityLabel if view.options.entityLabel
        prefix

    result.initOperatorsVisibility = (operators) ->
        for o in operators
            if @feature.isPermitted(getPermissionId(o.id))
                $op = @$ o.id
                if o.show in ['always', 'unselected'] then $op.show() else $op.hide()

    result.ensureOperatorsVisibility = (operators, selected) ->
        for o in operators
            if @feature.isPermitted(getPermissionId(o.id))
                continue if o.show is 'always'

                $op = @$(o.id)
                if selected
                    if _.isArray selected
                        if selected.length is 0
                            if o.show is 'unselected' then $op.show() else $op.hide()
                        else if selected.length is 1
                            if o.show in ['selected', 'single-selected'] then $op.show() else $op.hide()
                        else
                            if o.show in ['selected', 'multi-selected'] then $op.show() else $op.hide()
                    else
                        if not o.show or o.show in ['selected', 'single-selected'] then $op.show() else $op.hide()
                else
                    if o.show is 'unselected' then $op.show() else $op.hide()

    result.extendEventHandlers = (view, handlers) ->
        scaffold = view.feature.options.scaffold or {}
        eventHandlers = _.extend {}, handlers, scaffold.handlers
        _.extend view.eventHandlers, eventHandlers

    result.submitHandler = (options, viewName, title, type) ->
        view = @feature.views[viewName]
        id = view.model.get 'id'
        app = @feature.module.getApplication()
        scaffold = @feature.options.scaffold or {}

        if _.isFunction scaffold.beforeShowDialog
            if (scaffold.beforeShowDialog.call view, type, view) isnt true
                view.model.clear()
                return

        ok = ->
            view.submit(id: id).done (data) ->
                options.submitSuccess(type)
                app._modalDialog.modal.modal 'hide'

                if _.isFunction scaffold.afterCloseDialog
                    scaffold.afterCloseDialog.call view, type, view, data
            false

        app.showDialog(
            view: view
            title: title
            buttons: [label: '确定', status: 'btn-primary', fn: ok]
            onClose: ->
                view.model.clear()
        ).done (dialog) ->
            view.setFormData(view.model.toJSON())
            if _.isFunction scaffold.afterShowDialog
                scaffold.afterShowDialog.call view, type, view, view.model.toJSON()

    result.generateOperatorsView = (options, module, feature, deferred) ->
        feature.request(url: options.url or 'configuration/operators').done (data) ->
            events = {}
            delegates = {}
            ops = []
            opGroups = {}
            for name, value of data
                value = label: value if _.isString value
                value.id = name
                value.style or value.style = 'btn-primary'
                value.label or value.label = ''

                group = value.group or 'default'
                groups = opGroups[group] or (opGroups[group] = [])
                groups.push value
                ops.push value
            for name, value of opGroups
                for o in value
                    o.icon = 'icon-file' if not o.icon
                    o.HTML = result.templates.operator o
                    o.order = 10000 if not o.order
                    events['click ' + o.id] = o.id
                    delegates['click ' + o.id] = 'click:' + o.id if o.publish is true
                opGroups[name] = _.sortBy value, (item) -> item.order
            groupNames = _.keys(opGroups).sort()

            events['click filter'] = 'toggleFilter'
            viewOptions =
                baseName: 'operators'
                module: module
                feature: feature
                events: events
                delegates: delegates
                operators: ops
                avoidLoadingHandlers: true
                extend:
                    renderHtml: (su, data) ->
                        html = (result.templates.buttonGroup buttons: (v.HTML for v in opGroups[name]).join('') for name in groupNames).join('')
                        if @feature.options.haveFilter and @feature.isPermitted('show')
                            html += '<div class="pull-right btn-group"><button id="filter" class="btn btn-warning c-filter-toggle"><i class="icon-chevron-down"/></button></div>'

                        template = Handlebars.compile html
                        template(data)

            view = if options.createView then options.createView(viewOptions) else new View(viewOptions)
            result.extendEventHandlers view, options.handlers
            view.eventHandlers.toggleFilter = ->
                @feature.views['form:filter'].reset()
                @feature.layout.$('filter-container').toggle()
                $(window).scroll() #fix the FixedHeader issue

            deferred.resolve view

    result.generateGridView = (options, module, feature, deferred) ->
        feature.request(url: options.url or 'configuration/grid').done (data) ->
            data.type = 'grid'
            data.selector = 'grid'
            data.pager = 'pager'
            _.extend data, feature.options.gridOptions, feature.startupOptions.gridOptions
            events = _.extend
                'window#resize': 'adjustGridHeight'
                'xhr': 'deferAdjustGridHeight'
            , data.events

            viewOptions =
                baseName: 'grid'
                module: module
                feature: feature
                components: [data]
                avoidLoadingHandlers: true
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

            viewOptions =
                baseName: 'tree'
                module: module
                feature: feature
                components: [data]
                events: data.events or {}
                avoidLoadingHandlers: true
                extend:
                    renderHtml: (su, data) ->
                        result.templates.tree

            view = if options.createView then options.createView(viewOptions) else new View(viewOptions)
            result.extendEventHandlers view, options.handlers
            deferred.resolve view

    result
