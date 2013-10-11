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
        (if @feature.isPermitted(getPermissionId(o.id)) then @$(o.id).show()) for o in operators when ['add', 'refresh'].indexOf(o.id) isnt -1

    result.ensureOperatorsVisibility = (operators, id) ->
        (if id and @feature.isPermitted(getPermissionId(o.id)) then @$(o.id).show() else @$(o.id).hide()) for o in operators when ['edit', 'del', 'show'].indexOf(o.id) isnt -1

    result.extendEventHandlers = (view, handlers) ->
        scaffold = view.feature.options.scaffold or {}
        eventHandlers = _.extend {}, handlers, scaffold.handlers
        _.extend view.eventHandlers, eventHandlers

    result.submitHandler = (options, viewName, title, type) ->
        view = @feature.views[viewName]
        id = view.model.get 'id'
        app = @feature.module.getApplication()
        ok = ->
            view.submit(id: id).done (data) ->
                options.submitSuccess(type)
                app._modalDialog.modal.modal 'hide'
            false

        app.showDialog(
            view: view
            title: title
            buttons: [label: '确定', status: 'btn-primary', fn: ok]
            onClose: ->
                view.model.clear()
        ).done (dialog) ->
            v = dialog.startupOptions.view
            v.setFormData(v.model.toJSON())

    result.generateOperatorsView = (options, module, feature, deferred) ->
        feature.request(url: options.url or 'configuration/operators').done (data) ->
            strings = {}
            events = {}
            delegates = {}
            ops = []
            opGroups = {}
            for name, value of data
                value = label: value if _.isString value
                value.id = name
                value.style or value.style = ''
                value.label or value.label = ''

                group = value.group or 'default'
                groups = opGroups[group] or (opGroups[group] = [])
                groups.push value
                ops.push value
            for name, value of opGroups
                strings[name] = []
                for o in value
                    o.icon = 'icon-file' if not o.icon
                    strings[name].push result.templates.operator o
                    events['click ' + o.id] = o.id
                    delegates['click ' + o.id] = 'click:' + o.id if o.publish is true
            events['click filter'] = 'toggleFilter'
            events['click picker'] = 'showPicker'
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
                        html = (result.templates.buttonGroup buttons: value.join('') for name, value of strings).join('')
                        if @feature.options.haveFilter and @feature.isPermitted('show')
                            html += '<div class="pull-right btn-group"><button id="filter" class="btn btn-warning c-filter-toggle"><i class="icon-chevron-down"/></button></div>'

                        if @feature.startupOptions.inlineGrid?.picker
                            html += '<div class="pull-right btn-group"><a id="picker" class="btn btn-warning" href="javascript:void 0"><i class="icon-search"/> 选择</a></div>'
                        template = Handlebars.compile html
                        template(data)

            view = if options.createView then options.createView(viewOptions) else new View(viewOptions)
            result.extendEventHandlers view, options.handlers
            view.eventHandlers.toggleFilter = ->
                @feature.layout.$('filter-container').toggle()
                $(window).scroll() #fix the FixedHeader issue
            view.eventHandlers.showPicker = ->
                picker = @feature.layout.findComponent 'picker'
                return unless picker
                picker.chooser.show picker

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
