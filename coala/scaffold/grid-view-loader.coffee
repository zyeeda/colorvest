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
                    @feature.views['grid:body'].components[0].refresh()
            , 'form:add', viewLoader.getDialogTitle(@feature.views['form:add'], 'add', '新增')

        edit: ->
            grid = @feature.views['grid:body'].components[0]
            view = @feature.views['form:edit']
            app = @feature.module.getApplication()
            selected = grid.getSelected()
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            $.when(view.model.fetch()).then =>
                viewLoader.submitHandler.call @,
                    submitSuccess: (type) =>
                        @feature.views['grid:body'].components[0].refresh()
                , 'form:edit', viewLoader.getDialogTitle(@feature.views['form:edit'], 'edit', '编辑')

        del: ->
            grid = @feature.views['grid:body'].components[0]
            selected = grid.getSelected()
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            return @feature.removeManyToManyReference?(selected) if @feature.startupOptions.inlineGrid?.manyToMany

            if @feature.startupOptions.inlineGrid?.picker
                refKey = @feature.startupOptions.inlineGrid.refKey
                @feature.model.set selected
                @feature.model.set refKey, null
                @feature.model.save().done ->
                    grid.refresh()
                .always =>
                    @feature.model.clear()
                return

            app.confirm '确定要删除选中的记录吗?', (confirmed) =>
                return if not confirmed

                @feature.model.set selected
                $.when(@feature.model.destroy()).then (data) =>
                    grid.refresh()
                .always =>
                    @feature.model.clear()

        show: ->
            grid = @feature.views['grid:body'].components[0]
            view = @feature.views['form:show']
            selected = grid.getSelected()
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            $.when(view.model.fetch()).then =>
                app.showDialog(
                    view: view
                    onClose: ->
                        view.model.clear()
                    title: viewLoader.getDialogTitle(@feature.views['form:show'], 'show', '查看')
                    buttons: []
                ).done ->
                    view.setFormData view.model.toJSON()

        refresh: ->
            grid = @feature.views['grid:body'].components[0]
            grid.refresh()

    type: 'view'
    name: 'grid'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        if viewName is 'toolbar'
            viewLoader.generateOperatorsView
                handlers: handlers
            , module, feature, deferred
        else if viewName is 'body'
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
                        v = @feature.views['grid:toolbar']
                        visibility.call v, v.options.operators, models
                    refresh: () ->
                        v = @feature.views['grid:toolbar']
                        initVisibility.call v, v.options.operators
            , module, feature, deferred

        deferred
