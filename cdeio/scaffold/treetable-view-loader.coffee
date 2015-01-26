define [
    'jquery'
    'underscore'
    'cdeio/core/view'
    'cdeio/core/config'
    'cdeio/scaffold/abstract-view-loader'
], ($, _, View, config, viewLoader) ->

    handlers =
        add: ->
            @feature.views['form:add'].model.clear()
            grid = @feature.views['treetable:body'].components[0]
            selected = grid.getSelected()
            if selected
                rowData = selected.toJSON()
                @feature.views['form:add'].model.set 'parent', rowData

            viewLoader.submitHandler.call @,
                submitSuccess: (type) =>
                    #data = @feature.views['form:add'].model.toJSON()
                    #grid.addChildNode data.id, selected, data
                    grid.refresh()
            , 'form:add', viewLoader.getDialogTitle(@feature.views['form:add'], 'add', '新增')

        edit: ->
            grid = @feature.views['treetable:body'].components[0]
            view = @feature.views['form:edit']
            app = @feature.module.getApplication()
            selected = grid.getSelected()
            return app.info '请选择要操作的记录' if not selected

            view.model.set 'id', selected.id
            if selected
                rowData = selected.toJSON()
                @feature.views['form:edit'].model.set 'parent', rowData

            $.when(view.model.fetch()).then =>
                viewLoader.submitHandler.call @,
                    submitSuccess: (type) =>
                        ###
                        ###
                        grid.setTreeRow selected, view.model.toJSON()
                , 'form:edit', viewLoader.getDialogTitle(@feature.views['form:edit'], 'edit', '编辑')

        del: ->
            gridView = @feature.views['treetable:body']
            grid = gridView.components[0]
            selected = grid.getGridParam('selrow')
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            scaffold = gridView.feature.options.scaffold or {}
            _handlers = scaffold.handlers or {}
            if _.isFunction _handlers.beforeDel
                return if (_handlers.beforeDel.call gridView, gridView, grid, selected.toJSON()) is false

            app.confirm '确定要删除选中的记录吗?', (confirmed) =>
                return if not confirmed

                @feature.model.set 'id', selected
                $.when(@feature.model.destroy()).then (data) =>
                    grid.delTreeNode selected
                    grid.trigger 'reloadGrid'

        show: ->
            app = @feature.module.getApplication()
            grid = @feature.views['treetable:body'].components[0]
            view = @feature.views['form:show']
            selected = grid.getGridParam('selrow')
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            view.model.set 'id', selected
            $.when(view.model.fetch()).then =>
                app.showDialog(
                    view: view
                    title: viewLoader.getDialogTitle(@feature.views['form:show'], 'show', '查看')
                    buttons: []
                ).done ->
                    view.setFormData view.model.toJSON()
                    scaffold = view.feature.options.scaffold or {}
                    if _.isFunction scaffold.afterShowDialog
                        scaffold.afterShowDialog.call view, 'show', view, view.model.toJSON()

        refresh: ->
            grid = @feature.views['treetable:body'].components[0]
            grid.trigger('reloadGrid')


    type: 'view'
    name: 'treetable'
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
                url: 'configuration/tree-table'
                createView: (options) ->
                    options.events or= {}
                    options.events['selectionChanged grid'] = 'selectionChanged'
                    options.events['draw grid'] = 'refresh'
                    options.components[0].checkBoxColumn = false
                    options.components[0].options =
                        afterRequest: (data) ->
                            idMap = {}
                            idMap[i.id] = i for i in data
                            for i in data
                                if i.parent
                                    item = idMap[i.parent.id]
                                    item.children or = []
                                    item.children.push i
                            idMap = {}
                            d = []
                            visit = (node) ->
                                if not idMap[node.id]
                                    d.push node
                                    idMap[node.id] = true
                                    visit n for n in node.children or []

                            visit n for n in (i for i in data when not i.parent).concat data
                            d

                        sDom: 'Ttfr'
                        oTreeTable:
                            fnPreInit: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
                                r = $(nRow)
                                r.addClass('parent') if not aData.parent
                                r.data 'tt-id', aData.id
                                r.data 'tt-parent-id', aData.parent.id if aData.parent
                                nRow
                            showExpander: true

                    new View options
                handlers:
                    selectionChanged: (id, status) ->
                        return if not status
                        v = @feature.views['treetable:toolbar']
                        visibility.call v, v.options.operators, id
                    refresh: () ->
                        v = @feature.views['treetable:toolbar']
                        initVisibility.call v, v.options.operators
            , module, feature, deferred

        deferred
