define [
    'jquery'
    'underscore'
    'cdeio/core/view'
    'cdeio/core/config'
    'cdeio/scaffold/abstract-view-loader'
], ($, _, View, config, viewLoader) ->

    # 操作完成后刷新页面
    kit = 
        refresh: (feature) ->
            activeTab = feature.activeTab
            feature.activeTab = 'waiting'
            feature.views['process:body-waiting']?.components[0]?.refresh()
            feature.activeTab = 'doing'
            feature.views['process:body-doing']?.components[0]?.refresh()
            feature.activeTab = 'done'
            feature.views['process:body-done']?.components[0]?.refresh()
            feature.activeTab = 'none'
            feature.views['process:body-none']?.components[0]?.refresh()
            feature.activeTab = activeTab

    handlers =
        add: ->
            viewLoader.submitHandler.call @,
                submitSuccess: (type) =>
                    @feature.views['process:body-none'].components[0].refresh()
                    @feature.views['process:body-waiting']?.components[0]?.refresh()
            , 'process-form:add', '新增', 'add'

        edit: ->
            grid = @feature.views['process:body-'+@feature.activeTab].components[0]
            view = @feature.views['process-form:edit']
            app = @feature.module.getApplication()
            selected = grid.getSelected()
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            $.when(view.model.fetch()).then =>
                viewLoader.submitHandler.call @,
                    submitSuccess: (type) =>
                        @feature.views['process:body-'+@feature.activeTab].components[0].refresh()
                , 'process-form:edit', viewLoader.getDialogTitle(@feature.views['process-form:edit'], 'edit', '编辑'), 'edit'

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
            view = @feature.views['process-form:show']
            selected = grid.getSelected()
            view.model.set selected
            app = @feature.module.getApplication()
            return app.info '请选择要操作的记录' if not selected

            view.model.set selected
            claimButton = 
                label: '认领',
                status: 'btn-primary'
                fn: =>
                    app.confirm '确定认领此任务么?', (confirmed) =>
                        return if not confirmed
                        view = @feature.views['process-form:show']
                        # confirm 后， view下 model 的属性会消失 ？？？
                        selected = grid.getSelected()
                        view.model.set selected
                        id = view.model.get 'id'
                        view.model.taskOperatorType = 'claim'
                        view.submit(id: id).done (data) =>
                            delete view.model.taskOperatorType
                            kit.refresh @feature
                            @
            
            rejectButton = 
                label: '回退...',
                status: 'btn-inverse'
                fn: =>
                    v = @feature.views['process-form:reject']
                    btns = []
                    rejectBtn = 
                        label: '回退',
                        status: 'btn-inverse'
                        fn: =>
                            id = v.model.get 'id'
                            v.model.taskOperatorType = 'reject'
                            v.dialogFeature.close()

                            v.submit(id: id).done (data) =>
                                view.dialogFeature.modal.modal "hide"
                                delete v.model.taskOperatorType
                                kit.refresh @feature
                                @
                            false
                    btns.push rejectBtn
                    app.showDialog(
                        view: v
                        onClose: ->
                            view.model.clear()
                        title: '回退任务'
                        buttons: btns
                    ).done ()->
                        view.setFormData view.model.toJSON()
                    false # 点击按钮后是否关闭窗口
            recallButton = 
                label: '召回...',
                status: 'btn-inverse'
                fn: =>
                    # app.confirm '确定召回此任务么?', (confirmed) =>
                    #     return if not confirmed
                    #     selected = grid.getSelected()
                    #     view.model.set selected
                    #     id = view.model.get 'id'
                    #     view.model.taskOperatorType = 'recall'
                    #     view.submit(id: id).done (data) =>
                    #         delete view.model.taskOperatorType
                    #         kit.refresh @feature
                    #         @
                    
                    # 增加召回原因，由于目前流程任务只能在完成之前添加 comment， 
                    # 所以此项功能尚无法启用
                    v = @feature.views['process-form:recall']
                    btns = []
                    recallBtn = 
                        label: '召回',
                        status: 'btn-inverse'
                        fn: =>
                            id = v.model.get 'id'
                            v.model.taskOperatorType = 'recall'
                            v.dialogFeature.close()

                            v.submit(id: id).done (data) =>
                                view.dialogFeature.modal.modal "hide"
                                delete v.model.taskOperatorType
                                kit.refresh @feature
                                @
                            false
                    btns.push recallBtn
                    app.showDialog(
                        view: v
                        onClose: ->
                            view.model.clear()
                        title: '召回任务'
                        buttons: btns
                    ).done ()->
                        view.setFormData view.model.toJSON()
                    false # 点击按钮后是否关闭窗口

            completeButton = 
                label: '完成...',
                status: 'btn-success'
                fn: =>
                    v = @feature.views['process-form:complete']
                    btns = []
                    completeBtn = 
                        label: '完成',
                        status: 'btn-success'
                        fn: =>
                            id = v.model.get 'id'
                            v.model.taskOperatorType = 'complete'
                            v.dialogFeature.close()

                            v.submit(id: id).done (data) =>
                                view.dialogFeature.modal.modal "hide"
                                delete v.model.taskOperatorType
                                kit.refresh @feature
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
            else if @feature.activeTab is 'doing'
                buttons.push completeButton

            $.when(view.model.fetch()).then =>
                view.model._t_taskId = view.model.get '_t_taskId'
                # 回退按钮, 可以回退并且已经被认领的情况下显示
                buttons.push rejectButton if view.model.get('_t_rejectable') is true
                # 召回按钮
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
            # grid.addParam('_task_type', @feature.activeTab) 
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
