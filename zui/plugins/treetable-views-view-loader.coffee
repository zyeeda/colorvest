define [
    'jquery'
    'underscore'
    'zui/coala/view'
    'zui/coala/config'
    'zui/plugins/abstract-view-loader'
], ($, _, View, config, viewLoader) ->

    handlers =
        add: ->
            @feature.views['forms:add'].model.clear()
            grid = @feature.views['treeTableViews:grid'].components[0]
            selected = grid.getGridParam('selrow')
            if selected
                rowData = grid.getRowData selected
                rowData.id = selected
                @feature.views['forms:add'].model.set 'parent', rowData

            viewLoader.submitHandler.call @,
                submitSuccess: (type) =>
                    #data = @feature.views['forms:add'].model.toJSON()
                    #grid.addChildNode data.id, selected, data
                    grid.trigger 'reloadGrid'
            , 'forms:add', viewLoader.getDialogTitle(@feature.views['forms:add'], 'add', '新增')
        edit: ->
            grid = @feature.views['treeTableViews:grid'].components[0]
            view = @feature.views['forms:edit']
            app = @feature.module.getApplication()
            selected = grid.getGridParam('selrow')
            return app.info '请选择要操作的记录' if not selected

            view.model.set 'id', selected
            if selected
                rowData = grid.getRowData selected
                rowData.id = selected
                @feature.views['forms:add'].model.set 'parent', rowData

            $.when(view.model.fetch()).then =>
                viewLoader.submitHandler.call @,
                    submitSuccess: (type) =>
                        grid.setTreeRow selected, view.model.toJSON()
                , 'forms:edit', viewLoader.getDialogTitle(@feature.views['forms:edit'], 'edit', '编辑')
        del: ->
            grid = @feature.views['treeTableViews:grid'].components[0]
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
                grid.delTreeNode selected
                grid.trigger 'reloadGrid'
        show: ->
            app = @feature.module.getApplication()
            grid = @feature.views['treeTableViews:grid'].components[0]
            view = @feature.views['forms:edit']
            selected = grid.getGridParam('selrow')
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            view.model.set 'id', selected
            $.when(view.model.fetch()).then =>
                app.showDialog(
                    view: view
                    title: viewLoader.getDialogTitle(@feature.views['forms:edit'], 'show', '查看')
                    buttons: []
                ).done ->
                    view.$$('form input').attr('readonly', true)
        refresh: ->
            grid = @feature.views['treeTableViews:grid'].components[0]
            grid.trigger('reloadGrid')


    type: 'view'
    name: 'treeTableViews'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        if viewName is 'operators'
            viewLoader.generateOperatorsView
                handlers: handlers
            , module, feature, deferred
        else if viewName is 'grid'
            scaffold = feature.options.scaffold or {}
            visibility = scaffold.ensureOperatorsVisibility or viewLoader.ensureOperatorsVisibility
            initVisibility = scaffold.initOperatorsVisibility or viewLoader.initOperatorsVisibility
            viewLoader.generateGridView
                url: 'configuration/tree-table'
                createView: (options) ->
                    options.components[0].onSelectRow = 'selectionChanged'
                    options.components[0].beforeRequest = 'refresh'
                    options.components[0].type = 'tree-table'
                    new View options
                handlers:
                    selectionChanged: (id, status) ->
                        console.log id,'id'
                        return if not status
                        v = @feature.views['treeTableViews:operators']
                        visibility.call v, v.options.operators, id
                    refresh: () ->
                        v = @feature.views['treeTableViews:operators']
                        initVisibility.call v, v.options.operators
            , module, feature, deferred

        deferred
