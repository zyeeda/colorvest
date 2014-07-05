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
                    @feature.views['process:body-none'].components[0].refresh()
                    @feature.views['process:body-waiting']?.components[0]?.refresh()
            # , 'process-form:add', viewLoader.getDialogTitle(@feature.views['process-form:add'], 'add', '新增'), 'add'
            , 'process-form:add', '新增', 'add'

        edit: ->
            grid = @feature.views['process:body-'+@feature.activeTab].components[0]
            view = @feature.views['form:edit']
            app = @feature.module.getApplication()
            selected = grid.getSelected()
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            $.when(view.model.fetch()).then =>
                viewLoader.submitHandler.call @,
                    submitSuccess: (type) =>
                        @feature.views['process:body-'+@feature.activeTab].components[0].refresh()
                , 'form:edit', viewLoader.getDialogTitle(@feature.views['form:edit'], 'edit', '编辑'), 'edit'

        del: ->
            grid = @feature.views['process:body-'+@feature.activeTab].components[0]
            selected = grid.getSelected()
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            app.confirm '确定要删除选中的记录吗?', (confirmed) =>
                return if not confirmed

                @feature.model.set selected
                $.when(@feature.model.destroy()).then (data) =>
                    grid.refresh()
                .always =>
                    @feature.model.clear()

        show: ->
            grid = @feature.views['process:body-'+@feature.activeTab].components[0]
            viewName = 'process-form:show'
            view = @feature.views[viewName]
            selected = grid.getSelected()
            view.model.set selected
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            claimButton = 
                label: '认领',
                status: 'btn-primary'
                fn: =>
                    id = view.model.get 'id'
                    view.model.taskOperatorType = 'claim'
                    view.submit(id: id).done (data) =>
                        view.model.taskOperatorType = undefined
                        @feature.views['process:body-waiting'].components[0].refresh()
                        @feature.views['process:body-doing']?.components[0]?.refresh()
                        @
                    
            rejectButton = 
                label: '回退',
                status: 'btn-primary'
                fn: =>
                    id = view.model.get 'id'
                    view.model.taskOperatorType = 'reject'
                    view.submit(id: id).done (data) =>
                        view.model.taskOperatorType = undefined
                        @feature.views['process:body-waiting']?.components[0]?.refresh()
                        @feature.views['process:body-doing']?.components[0]?.refresh()
                        @feature.views['process:body-none']?.components[0]?.refresh()
                        @
            recallButton = 
                label: '召回',
                status: 'btn-primary'
                fn: =>
                    id = view.model.get 'id'
                    view.model.taskOperatorType = 'recall'
                    view.submit(id: id).done (data) =>
                        view.model.taskOperatorType = undefined
                        @feature.views['process:body-waiting']?.components[0]?.refresh()
                        @feature.views['process:body-doing']?.components[0]?.refresh()
                        @
            completeButton = 
                label: '完成',
                status: 'btn-primary'
                fn: =>
                    v = @feature.views['process-form:complete']
                    btns = []
                    completeBtn = 
                        label: '完成',
                        status: 'btn-primary'
                        fn: =>
                            id = v.model.get 'id'
                            window._v = v
                            window._view = view
                            v.model.taskOperatorType = 'complete'
                            v.dialogFeature.close()
                            # view.dialogFeature.close()
                            v.submit(id: id).done (data) =>
                                view.dialogFeature.modal.modal "hide"
                                v.model.taskOperatorType = undefined
                                @feature.views['process:body-doing']?.components[0]?.refresh()
                                @feature.views['process:body-waiting']?.components[0]?.refresh()
                                @feature.views['process:body-done']?.components[0]?.refresh()
                                @feature.views['process:body-none']?.components[0]?.refresh()
                                @
                            false
                    btns.push completeBtn
                    app.showDialog(
                        view: v
                        onClose: ->
                            view.model.clear()
                        title: '完成任务'
                        buttons: btns
                    ).done ()->
                        view.setFormData view.model.toJSON()
                    false # 点击按钮后是否关闭窗口
            
            buttons = []
            if @feature.activeTab is 'waiting'
                buttons.push claimButton
                buttons.push completeButton
                # buttons.push claimCompleteButton
            else if @feature.activeTab is 'doing'
                buttons.push completeButton
            # else if @feature.activeTab is 'done'
                # buttons.push recallButton

            $.when(view.model.fetch()).then =>
                view.model._t_taskId = view.model.get '_t_taskId'
                # 回退按钮
                buttons.push rejectButton if view.model.get('_t_rejectable') is true
                buttons.push recallButton if view.model.get('_t_recallable') is true
                app.showDialog(
                    view: view
                    onClose: ->
                        view.model.clear()
                    title: '查看'
                    buttons: buttons
                ).done ->
                    view.setFormData view.model.toJSON()
                    scaffold = view.feature.options.scaffold or {}
                    if _.isFunction scaffold.afterShowDialog
                        scaffold.afterShowDialog.call view, 'show', view, view.model.toJSON()

        refresh: ->
            grid = @feature.views['process:body-'+@feature.activeTab].components[0]
            grid.addParam('_task_type', @feature.activeTab) 
            grid.refresh()

    resetGridHeight = (table) ->
        el = $('.dataTables_scrollBody')
        return if el.size() is 0
        height = $(document.body).height() - el.offset().top - 5
        height = if height < 0 then 0 else height
        el.height height
        table.fnSettings().oInit.sScrollY = height

    type: 'view'
    name: 'process'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        # 加载 tab 列表
        if viewName is 'tabs'
            viewLoader.generateTabsView
                handlers: {}
                , module, feature, deferred

            # tab 加载完成后加载 toolbar 和 grid
            views = []
            # $.when(deferred).done ->
            #     # window._waiting = $("a[href='#waiting']")
            #     $("a[href='#waiting']").hide()
            #     # $('.t-waiting').hide()
            
        else if viewName.indexOf('toolbar-') is 0
            viewLoader.generateOperatorsView 
                url : 'configuration/process/operators/' + (feature.activeTab or 'waiting')
                handlers: handlers
            , module, feature, deferred
        # 加载记录列表
        else if viewName.indexOf('body-') is 0
            tabName = viewName.split('-')[1]
            scaffold = feature.options.scaffold or {}
            visibility = scaffold.ensureOperatorsVisibility or viewLoader.ensureOperatorsVisibility
            initVisibility = scaffold.initOperatorsVisibility or viewLoader.initOperatorsVisibility
            viewLoader.generateGridView
                url: 'configuration/process/grid/' + (feature.activeTab or 'waiting')
                createView: (options) ->
                    options.events or= {}
                    options.events['selectionChanged grid'] = 'selectionChanged'
                    options.events['draw grid'] = 'refresh'
                    options.extra = {}
                    options.extra['_task_type'] = feature.activeTab or 'none'
                    new View options
                handlers:
                    selectionChanged: (e, models) ->
                        v = @feature.views['process:toolbar-'+tabName]
                        visibility.call v, v.options.operators, models
                    refresh: ->
                        v = @feature.views['process:toolbar-'+tabName]
                        initVisibility.call v, v.options.operators
                    adjustGridHeight: -> resetGridHeight(@components[0])
                    deferAdjustGridHeight: -> _.defer => resetGridHeight(@components[0])
                , module, feature, deferred
        deferred
