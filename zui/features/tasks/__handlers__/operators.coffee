define ["jquery"], ($) ->
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



    audit: ->
        me = this
        grid = me.feature.views["grid"].components[0]
        ogrid = me.feature.views["completed-grid"].components[0]
        selected = grid.getGridParam("selrow")
        app = me.feature.module.getApplication().applicationRoot
        return app.info("请选择要操作的记录")  unless selected
        me.feature.model.set "id", selected
        $.when(me.feature.model.fetch()).done ->
            app.loadView(me.feature, "forms:" + selected).done (view) ->
                app.showDialog
                    view: view
                    title: "Task Process"
                    buttons: [
                        label: "Finish"
                        fn: ->
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
                        fn: ->
                            me.feature.request(url: "reject/" + selected).done ->
                                grid.trigger "reloadGrid"

                    ]



        true

