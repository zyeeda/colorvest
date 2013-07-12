define [
    'jquery'
    'underscore'
    'coala/core/view'
    'coala/core/config'
    'coala/scaffold/abstract-view-loader'
], ($, _, View, config, viewLoader) ->

    handlers =
        add: ->
            viewLoader.submitHandler.call @,
                submitSuccess: (type) =>
                    @feature.views['views:grid'].components[0].refresh()
            , 'forms:add', viewLoader.getDialogTitle(@feature.views['forms:add'], 'add', '新增')
        edit: ->
            grid = @feature.views['views:grid'].components[0]
            view = @feature.views['forms:edit']
            app = @feature.module.getApplication()
            selected = grid.getSelected()
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            $.when(view.model.fetch()).then =>
                viewLoader.submitHandler.call @,
                    submitSuccess: (type) =>
                        @feature.views['views:grid'].components[0].refresh()
                , 'forms:edit', viewLoader.getDialogTitle(@feature.views['forms:edit'], 'edit', '编辑')
        del: ->
            grid = @feature.views['views:grid'].components[0]
            selected = grid.getSelected()
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            app.confirm '确定要删除选中的记录吗?', =>
                @feature.model.set selected
                $.when(@feature.model.destroy()).then (data) =>
                    if data.violations
                        msg = ''; summary = ''
                        for err in data.violations
                            unless err.properties
                                summary += err.message + '\n'
                        msg += summary
                        app.error msg, '验证提示'
                        return
                    grid.refresh()
        show: ->
            grid = @feature.views['views:grid'].components[0]
            view = @feature.views['forms:show']
            selected = grid.getSelected()
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            $.when(view.model.fetch()).then =>
                app.showDialog(
                    view: view
                    title: viewLoader.getDialogTitle(@feature.views['forms:show'], 'show', '查看')
                    buttons: []
                ).done ->
                    view.setFormData view.model.toJSON()
        refresh: ->
            grid = @feature.views['views:grid'].components[0]
            grid.refresh()

    type: 'view'
    name: 'views'
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
                createView: (options) ->
                    options.events or= {}
                    options.events['selectionChanged grid'] = 'selectionChanged'
                    options.events['draw grid'] = 'refresh'
                    new View options
                handlers:
                    selectionChanged: (e, models) ->
                        v = @feature.views['views:operators']
                        visibility.call v, v.options.operators, models
                    refresh: () ->
                        v = @feature.views['views:operators']
                        initVisibility.call v, v.options.operators
            , module, feature, deferred

        deferred
