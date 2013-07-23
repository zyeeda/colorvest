define [
    'jquery'
    'underscore'
    'coala/core/view'
    'coala/core/config'
    'coala/scaffold/abstract-view-loader'
], ($, _, View, config, viewLoader) ->

    handlers =
        add: ->
            @feature.views['forms:add'].model.clear()
            tree = @feature.views['treeViews:tree'].components[0]
            selected = tree.getSelectedNodes()[0]
            @feature.views['forms:add'].model.set 'parent', selected if selected
            viewLoader.submitHandler.call @,
                submitSuccess: =>
                    @feature.views['forms:add'].model.set isParent: true
                    tree.addNodes selected, @feature.views['forms:add'].model.toJSON()
            , 'forms:add', viewLoader.getDialogTitle(@feature.views['forms:add'], 'add', '新增'), 'add'

        edit: ->
            tree = @feature.views['treeViews:tree'].components[0]
            view = @feature.views['forms:edit']
            app = @feature.module.getApplication()
            selected = tree.getSelectedNodes()[0]
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            $.when(view.model.fetch()).then =>
                viewLoader.submitHandler.call @,
                    submitSuccess: ->
                        _.extend selected, view.model.toJSON()
                        tree.refresh()
                , 'forms:edit', viewLoader.getDialogTitle(@feature.views['forms:edit'], 'edit', '编辑'), 'edit'

        del: ->
            tree = @feature.views['treeViews:tree'].components[0]
            selected = tree.getSelectedNodes()[0]
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            app.confirm '确定要删除选中的记录吗?', =>
                @feature.model.set 'id', selected.id
                $.when(@feature.model.destroy()).then (data) =>
                    if data.violations
                        msg = ''; summary = ''
                        for err in data.violations
                            unless err.properties
                                summary += err.message + '\n'
                        msg += summary
                        app.error msg, '验证提示'
                        return
                    tree.removeNode selected

        show: ->
            app = @feature.module.getApplication()
            tree = @feature.views['treeViews:tree'].components[0]
            selected = tree.getSelectedNodes()[0]
            view = @feature.views['forms:show']
            return app.info '请选择要操作的记录' if not selected

            view.model.set 'id', selected.id
            $.when(view.model.fetch()).then =>
                app.showDialog(
                    view: view
                    title: viewLoader.getDialogTitle(@feature.views['forms:show'], 'show', '查看')
                    buttons: []
                ).done ->
                    view.setFormData view.model.toJSON()

        refresh: ->
            tree = @feature.views['treeViews:tree'].components[0]
            tree.reload()

    type: 'view'
    name: 'treeViews'
    fn: (module, feature, viewName, args) ->
        scaffold = feature.options.scaffold or {}
        visibility = scaffold.ensureOperatorsVisibility or viewLoader.ensureOperatorsVisibility
        initVisibility = scaffold.initOperatorsVisibility or viewLoader.initOperatorsVisibility
        deferred = $.Deferred()
        if viewName is 'operators'
            viewLoader.generateOperatorsView
                handlers: handlers
            , module, feature, deferred
        else if viewName is 'tree'
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
                            v = @feature.views['treeViews:operators']
                            initVisibility.call v, v.options.operators
                    selectionChanged: (e, treeId, node, status) ->
                        return if not status
                        v = @feature.views['treeViews:operators']
                        visibility.call v, v.options.operators, node.id
            , module, feature, deferred

            deferred.done (v) ->
                v.collection.on 'reset', ->
                    v = @feature.views['treeViews:operators']
                    initVisibility.call v, v.options.operators

        deferred
