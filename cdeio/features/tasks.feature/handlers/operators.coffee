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
        isRejectable = _.every selected, (v) ->
            view.collection.get(v).get('isRejectable') is true
        if selected.length is 1
            @$('audit').show()
            @$('reject').show() if isRejectable
        else if selected.length > 1
            @$('batchReject').show() if isRejectable
            @$('batchAudit').show()

    audit: ->
        grid = @feature.views["grid"].components[0]
        ogrid = @feature.views["completed-grid"].components[0]
        selected = grid.getSelected()
        app = @feature.module.getApplication()
        return app.info("请选择要操作的记录")  if selected.length is 0
        selected = selected[0].id

        @feature.model.set "id", selected
        $.when(@feature.model.fetch()).done =>
            app.loadView(@feature, "form:" + selected).done (view) =>
                buttons = [
                    label: "Finish"
                    fn: =>
                        getFormData view
                        valid = view.$$("form").valid()
                        return false  unless valid
                        view.model.set "id", selected
                        view.model.save().done ->
                            grid.reload()
                            ogrid.reload()

                        true
                ]

                if @feature.model.get('task').isRejectable
                    buttons.push
                        label: "Reject"
                        fn: =>
                            @feature.request(url: "reject/" + selected, type: 'put', data: comment: '').done ->
                                grid.refresh()
                                ogrid.refresh()

                app.showDialog
                    view: view
                    title: "Task Process"
                    buttons: buttons
        true

    batchAudit: ->
        grid = @feature.views['grid'].components[0]
        ogrid = @feature.views["completed-grid"].components[0]
        selected = grid.getSelected()
        app = @feature.module.getApplication()
        return app.info("请选择要操作的记录")  if selected.length is 0
        selected = (m.id for m in selected)

        app.confirm 'are you sure to audit these tasks?', (sure) =>
            return if not sure

            @feature.request(url: 'batch/audit', type: 'post', data: ids: selected).done ->
                grid.refresh()
                ogrid.refresh()

    reject: ->
        grid = @feature.views["grid"].components[0]
        ogrid = @feature.views["completed-grid"].components[0]
        selected = grid.getSelected()
        app = @feature.module.getApplication()
        return app.info("请选择要操作的记录")  if selected.length is 0
        selected = selected[0].id

        app.prompt 'why this task is rejected?', (str) =>
            return if str is null
            return app.info '请填写意见' if not str

            @feature.request(url: 'reject/' + selected, type: 'put', data: comment: str).done ->
                grid.refresh()
                ogrid.refresh()

    batchReject: ->
        grid = @feature.views['grid'].components[0]
        ogrid = @feature.views["completed-grid"].components[0]
        selected = grid.getSelected()
        app = @feature.module.getApplication()
        return app.info("请选择要操作的记录")  if selected.length is 0
        selected = (m.id for m in selected)

        app.prompt 'why these tasks are rejected?', (str) =>
            return if str is null
            return app.info '请填写意见' if not str

            @feature.request(url: 'batch/reject', type: 'post', data: {ids: selected, comment: str}).done ->
                grid.refresh()
                ogrid.refresh()
