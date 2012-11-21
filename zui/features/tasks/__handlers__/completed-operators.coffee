define ["jquery", "zui/coala/loader-plugin-manager"], ($, LoaderManager) ->
    viewIt: ->
        me = this
        grid = me.feature.views["completed-grid"].components[0]
        gridView = me.feature.views["completed-grid"]
        selected = grid.getGridParam("selrow")
        app = me.feature.module.getApplication().applicationRoot
        return app.info("请选择要操作的记录")  unless selected
        gridView.model.set "id", selected
        $.when(gridView.model.fetch()).done ->
            LoaderManager.invoke("view", me.feature.module, me.feature, "forms:" + selected).done (view) ->
                view.model = gridView.model
                app.showDialog
                    view: view
                    title: "Task Process"
                    buttons: [
                        label: "Revoke"
                        fn: ->
                            me.feature.request(url: "revoke/" + selected).done ->
                                grid.trigger "reloadGrid"

                    ]



        true

