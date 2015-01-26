define ->
    tabChange: ->
        console.log 'active tab  changed...'

    # 获取待办列表
    doWaiting: ->
        @feature.activeTab = 'waiting'

        if not @feature.views['process:body-waiting']
            views = []
            views.push name: 'process:toolbar-waiting', region: 'toolbar-waiting' # 操作按钮
            views.push name: 'process:body-waiting', region: 'body-waiting' # 对应标签下的列表内容
            views.push 'process-form:show' if not @feature.views['process-form:show']
            views.push 'process-form:complete' if not @feature.views['process-form:complete']

            deferredView = @feature.initViews views
            _feature = @feature
            deferredView.done ()->
                _feature.layout['toolbar_waiting'].show _feature.views['process:toolbar-waiting']
                _feature.layout['body_waiting'].show _feature.views['process:body-waiting']

        $('.c-doing').hide()
        $('.c-done').hide()
        $('.c-none').hide()                
        $('.c-waiting').show()

    # 获取在办列表
    doDoing: ->
        @feature.activeTab = 'doing'

        if not @feature.views['process:body-doing']
            views = []
            views.push name: 'process:toolbar-doing', region: 'toolbar-doing' # 操作按钮
            views.push name: 'process:body-doing', region: 'body-doing' # 对应标签下的列表内容
            views.push 'process-form:show' if not @feature.views['process-form:show']
            views.push 'process-form:complete' if not @feature.views['process-form:complete']
            views.push 'process-form:reject' if not @feature.views['process-form:reject']

            deferredView = @feature.initViews views
            _feature = @feature
            deferredView.done ()->
                _feature.layout['toolbar_doing'].show _feature.views['process:toolbar-doing']
                _feature.layout['body_doing'].show _feature.views['process:body-doing']

        $('.c-waiting').hide()
        $('.c-done').hide()
        $('.c-none').hide()
        $('.c-doing').show()

    # 获取已办列表
    doDone: ->
        @feature.activeTab = 'done'

        if not @feature.views['process:body-done']
            views = []
            views.push name: 'process:toolbar-done', region: 'toolbar-done' # 操作按钮
            views.push name: 'process:body-done', region: 'body-done' # 对应标签下的列表内容
            views.push 'process-form:show' if not @feature.views['process-form:show']

            deferredView = @feature.initViews views
            _feature = @feature
            deferredView.done ()->
                _feature.layout['toolbar_done'].show _feature.views['process:toolbar-done']
                _feature.layout['body_done'].show _feature.views['process:body-done']

        $('.c-waiting').hide()
        $('.c-doing').hide()
        $('.c-none').hide()                 
        $('.c-done').show()

    # 获取所有记录列表
    doAll: ->
        @feature.activeTab = 'none'

        if not @feature.views['process:body-none']
            views = []
            views.push name: 'process:toolbar-none', region: 'toolbar-none' # 操作按钮
            views.push name: 'process:body-none', region: 'body-none' # 对应标签下的列表内容

            views.push 'process-form:add'
            views.push 'process-form:edit'
            views.push 'process-form:show'

            deferredView = @feature.initViews views
            _feature = @feature
            deferredView.done ()->
                _feature.layout['toolbar_none'].show _feature.views['process:toolbar-none']
                _feature.layout['body_none'].show _feature.views['process:body-none']

        $('.c-waiting').hide()
        $('.c-doing').hide()
        $('.c-done').hide()
        $('.c-none').show()

    # 发起信息
    doWrite: ->
        