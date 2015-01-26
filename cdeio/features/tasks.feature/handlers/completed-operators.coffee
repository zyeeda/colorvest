define ["jquery", "cdeio/core/loader-plugin-manager"], ($, LoaderManager) ->
    viewIt: ->
        me = this
        grid = me.feature.views["completed-grid"].components[0]
        gridView = me.feature.views["completed-grid"]
        selected = grid.getSelected()
        app = me.feature.module.getApplication()
        return app.info("请选择要操作的记录")  unless selected
        selected = selected.id

        gridView.model.set "id", selected
        $.when(gridView.model.fetch()).done ->
            LoaderManager.invoke("view", me.feature.module, me.feature, "form:p" + selected).done (view) ->
                view.model = gridView.model
                app.showDialog
                    view: view
                    title: "Task Process"
                    buttons: [
                        label: "Revoke"
                        status: 'disabled'
                        fn: (btn) ->
                            me.feature.request(url: "revoke/" + btn.taskId).done ->
                                grid.refresh()
                    ]
        true

    selectAll: ->
        grid = @feature.views["completed-grid"].components[0]
        grid.addParam 'status', null
        grid.refresh()

    selectFinished: ->
        grid = @feature.views["completed-grid"].components[0]
        grid.addParam 'status', 'finished'
        grid.refresh()

    selectUnfinished: ->
        grid = @feature.views["completed-grid"].components[0]
        grid.addParam 'status', 'unfinished'
        grid.refresh()
