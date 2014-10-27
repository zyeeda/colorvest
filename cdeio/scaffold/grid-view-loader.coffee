define [
    'jquery'
    'underscore'
    'cdeio/core/view'
    'cdeio/core/config'
    'cdeio/scaffold/abstract-view-loader'
], ($, _, View, config, viewLoader) ->

    handlers =
        add: ->
            viewLoader.submitHandler.call @,
                submitSuccess: (type) =>
                    @feature.views['grid:body'].components[0].refresh()
            , 'form:add', viewLoader.getDialogTitle(@feature.views['form:add'], 'add', '新增'), 'add'

        edit: ->
            grid = @feature.views['grid:body'].components[0]
            view = @feature.views['form:edit']
            app = @feature.module.getApplication()
            selected = grid.getSelected()
            return app.info '请选择要操作的记录' if not selected
            selected = selected[0] if selected instanceof Array

            view.model.set selected
            $.when(view.model.fetch()).then =>
                viewLoader.submitHandler.call @,
                    submitSuccess: (type) =>
                        @feature.views['grid:body'].components[0].refresh()
                , 'form:edit', viewLoader.getDialogTitle(@feature.views['form:edit'], 'edit', '编辑'), 'edit'

        del: ->
            gridView = @feature.views['grid:body']
            grid = gridView.components[0]
            selected = grid.getSelected()
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected
            selected = selected[0] if selected instanceof Array

            scaffold = gridView.feature.options.scaffold or {}
            _handlers = scaffold.handlers or {}
            if _.isFunction _handlers.beforeDel
                return if (_handlers.beforeDel.call gridView, gridView, grid, selected.toJSON()) is false

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
            selected = selected[0] if selected instanceof Array

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
                    scaffold = view.feature.options.scaffold or {}
                    if _.isFunction scaffold.afterShowDialog
                        scaffold.afterShowDialog.call view, 'show', view, view.model.toJSON()

        refresh: ->
            grid = @feature.views['grid:body'].components[0]
            grid.refresh()

    resetGridHeight = (table) ->
        el = $('.dataTables_scrollBody')
        return if el.size() is 0
        height = $(document.body).height() - el.offset().top - 5
        height = if height < 0 then 0 else height
        el.height height
        table.fnSettings().oInit.sScrollY = height

        # 在获取页面的 offsetHeight 高度时是包括了浏览器的边框的, 浏览器的边框是 2 个像素, 减去左右两个边框就是 4 个像素
        if el[0].clientWidth < el[0].offsetWidth - 4
            $('.dataTables_scrollHead').css 'width', el.width() - 15

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
                    refresh: ->
                        v = @feature.views['grid:toolbar']
                        initVisibility.call v, v.options.operators
                    adjustGridHeight: ->
                        resetGridHeight(@components[0]) if @components and @components[0]
                    deferAdjustGridHeight: -> _.defer =>
                        resetGridHeight(@components[0]) if @components and @components[0]
            , module, feature, deferred

        deferred
