define ["jquery", 'underscore'], ($, _) ->
    getFormData = (view) ->
        values = view.$$("form").serializeArray()
        data = {}
        _(values).map (item) ->
            if item.name of data
                if _.isArray(data[item.name])
                    data[item.name] = data[item.name].concat([item.value])
                else
                    data[item.name] = [data[item.name], item.value]
            else
                data[item.name] = item.value
            view.model.set data
            _(view.components).each (component) ->
                if _.isFunction(component.getFormData)
                    d = component.getFormData()
                    view.model.set d.name, d.value  if d


    initSelection: (feature, view, grid, args...) ->
        @$('audit').hide()
        @$('batchAudit').hide()
        @$('reject').hide()
        @$('batchReject').hide()

    selectChanged: (feature, view, grid, args...) ->
        @$('audit').hide()
        @$('batchAudit').hide()
        @$('reject').hide()
        @$('batchReject').hide()
        selected = grid.getGridParam('selarrrow')
        if selected.length is 1
            @$('audit').show()
            @$('reject').show()
        else if selected.length > 1
            @$('batchReject').show()
            @$('batchAudit').show()

    audit: ->
        grid = @feature.views["grid"].components[0]
        ogrid = @feature.views["completed-grid"].components[0]
        selected = grid.getGridParam("selrow")
        app = @feature.module.getApplication().applicationRoot
        return app.info("请选择要操作的记录")  unless selected
        @feature.model.set "id", selected
        $.when(@feature.model.fetch()).done =>
            app.loadView(@feature, "forms:" + selected).done (view) =>
                app.showDialog
                    view: view
                    title: "Task Process"
                    buttons: [
                        label: "Finish"
                        fn: =>
                            getFormData view
                            valid = view.$$("form").valid()
                            return false  unless valid
                            view.model.set "id", selected
                            view.model.save().done ->
                                grid.trigger "reloadGrid"
                                ogrid.trigger "reloadGrid"

                            true
                    ,
                        label: "Reject"
                        fn: =>
                            @feature.request(url: "reject/" + selected, type: 'put').done ->
                                grid.trigger "reloadGrid"
                                ogrid.trigger "reloadGrid"

                    ]

        true

    batchAudit: ->
        grid = @feature.views['grid'].components[0]
        ogrid = @feature.views["completed-grid"].components[0]
        selected = grid.getGridParam('selarrrow')
        app = @feature.module.getApplication().applicationRoot

        app.confirm 'are you sure to audit these tasks?', =>
            @feature.request(url: 'batch/audit', type: 'post', data: ids: selected).done ->
                grid.trigger 'reloadGrid'
                ogrid.trigger 'reloadGrid'

    reject: ->
        grid = @feature.views["grid"].components[0]
        ogrid = @feature.views["completed-grid"].components[0]
        selected = grid.getGridParam("selrow")
        app = @feature.module.getApplication().applicationRoot

        app.prompt 'why this task is rejected?', (str) =>
            console.log str, 'str'
            @feature.request(url: 'reject/' + selected, type: 'put', data: comment: str).done ->
                grid.trigger 'reloadGrid'
                ogrid.trigger 'reloadGrid'

    batchReject: ->
        grid = @feature.views['grid'].components[0]
        ogrid = @feature.views["completed-grid"].components[0]
        selected = grid.getGridParam('selarrrow')
        app = @feature.module.getApplication().applicationRoot

        app.prompt 'why this task is rejected?', (str) =>
            @feature.request(url: 'batch/reject', type: 'post', data: {ids: selected, comment: str}).done ->
                grid.trigger 'reloadGrid'
                ogrid.trigger 'reloadGrid'
