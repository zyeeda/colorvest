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
            tree = @feature.views['tree:body'].components[0]
            selected = tree.getSelectedNodes()[0]
            @feature.views['form:add'].model.set 'parent', selected if selected
            viewLoader.submitHandler.call @,
                submitSuccess: =>
                    @feature.views['form:add'].model.set isParent: true
                    selected = tree.getNodeByParam('id', '-1') if not selected
                    if selected and selected['__inited__'] is true
                        tree.addNodes selected, @feature.views['form:add'].model.toJSON(), false
                    else
                        tree.expandNode selected, true, false, true, true
            , 'form:add', viewLoader.getDialogTitle(@feature.views['form:add'], 'add', '新增'), 'add'

        edit: ->
            tree = @feature.views['tree:body'].components[0]
            view = @feature.views['form:edit']
            app = @feature.module.getApplication()
            selected = tree.getSelectedNodes()[0]
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            $.when(view.model.fetch()).then =>
                viewLoader.submitHandler.call @,
                    submitSuccess: ->
                        _.extend selected, view.model.toJSON()
                        tree.refresh()
                , 'form:edit', viewLoader.getDialogTitle(@feature.views['form:edit'], 'edit', '编辑'), 'edit'

        del: ->
            treeView = @feature.views['tree:body']
            tree = treeView.components[0]
            selected = tree.getSelectedNodes()[0]
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            scaffold = treeView.feature.options.scaffold or {}
            _handlers = scaffold.handlers or {}
            if _.isFunction _handlers.beforeDel
                return if (_handlers.beforeDel.call treeView, treeView, tree, selected.toJSON()) is false

            app.confirm '确定要删除选中的记录吗?', (confirmed) =>
                return if not confirmed

                @feature.model.set 'id', selected.id
                $.when(@feature.model.destroy()).then (data) =>
                    tree.removeNode selected

        show: ->
            app = @feature.module.getApplication()
            tree = @feature.views['tree:body'].components[0]
            selected = tree.getSelectedNodes()[0]
            view = @feature.views['form:show']
            return app.info '请选择要操作的记录' if not selected

            view.model.set 'id', selected.id
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
            tree = @feature.views['tree:body'].components[0]
            tree.reload()

    type: 'view'
    name: 'tree'
    fn: (module, feature, viewName, args) ->
        scaffold = feature.options.scaffold or {}
        visibility = scaffold.ensureOperatorsVisibility or viewLoader.ensureOperatorsVisibility
        initVisibility = scaffold.initOperatorsVisibility or viewLoader.initOperatorsVisibility
        deferred = $.Deferred()
        if viewName is 'toolbar'
            viewLoader.generateOperatorsView
                handlers: handlers
            , module, feature, deferred
        else if viewName is 'body'
            viewLoader.generateTreeView
                createView: (options) ->
                    options.events.click = 'clearSelection'
                    t = options.components[0]
                    t.callback or (t.callback = {})
                    t.callback.onClick = 'selectionChanged'
                    new View options
                handlers:
                    clearSelection: (e) ->
                        name = e.target.tagName
                        if name is 'LI' or name is 'UL'
                            @components[0].cancelSelectedNode()
                            v = @feature.views['tree:toolbar']
                            visibility.call v, v.options.operators
                    selectionChanged: (e, treeId, node, status) ->
                        return if not status
                        v = @feature.views['tree:toolbar']
                        visibility.call v, v.options.operators, node.id
            , module, feature, deferred

            deferred.done (v) ->
                v.collection.on 'reset', ->
                    v = @feature.views['tree:toolbar']
                    initVisibility.call v, v.options.operators

        deferred
